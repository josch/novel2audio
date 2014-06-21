#!/usr/bin/env python
# -*- coding: utf-8 -*-

import zipfile
from lxml import etree
import sys
import os
from operator import itemgetter
from re import split
import multiprocessing, subprocess

tempdir="/dev/shm"
cwd=os.getcwd()

ns = {
    'n':'urn:oasis:names:tc:opendocument:xmlns:container',
    'pkg':'http://www.idpf.org/2007/opf',
    'dc':'http://purl.org/dc/elements/1.1/',
    'ncx':'http://www.daisy.org/z3986/2005/ncx/',
    'xhtml':'http://www.w3.org/1999/xhtml'
}

if len(sys.argv) not in [2,3]:
    print "usage: %d epub [number]"
    exit(1)

fzip = zipfile.ZipFile(sys.argv[1])
txt = fzip.read('META-INF/container.xml')
tree = etree.fromstring(txt)
cfname = tree.xpath('n:rootfiles/n:rootfile/@full-path',namespaces=ns)[0]

pdir = os.path.dirname(cfname)

cf = fzip.read(cfname)
tree = etree.fromstring(cf)
ncxname = tree.xpath('/pkg:package/pkg:manifest/pkg:item[@id="ncx"]/@href',namespaces=ns)[0]

ncx = fzip.read(os.path.join(pdir, ncxname))
tree = etree.fromstring(ncx)
if len(sys.argv) == 2:
    navpoints = tree.xpath('/ncx:ncx/ncx:navMap/ncx:navPoint',namespaces=ns)
else:
    # the following xpath expression finds the subtree for the book we want to print
    navpoints = tree.xpath("/ncx:ncx/ncx:navMap/ncx:navPoint[starts-with(ncx:navLabel/ncx:text, 'Nr. %s')]/ncx:navPoint"%sys.argv[2],namespaces=ns)

title = tree.xpath("/ncx:ncx/ncx:navMap/ncx:navPoint/ncx:navLabel/ncx:text[starts-with(., 'Nr. %s')]/text()"%sys.argv[2], namespaces=ns)[0]

dnavpoint = list()

for navpoint in navpoints:
    r = lambda expr: navpoint.xpath(expr, namespaces=ns)[0]
    label = r('ncx:navLabel/ncx:text/text()')
    if label not in ['Cover', 'PERRY RHODAN - die Serie', 'Impressum']:
        order = int(r('@playOrder'))
        content = r('ncx:content/@src')
        dnavpoint.append((order, content))

# to be able to work offline, this needs the w3c-sgml-lib package
parser = etree.XMLParser(load_dtd=True)
i = 0
tasks = []
for _, pagename in sorted(dnavpoint, key=itemgetter(0)):
    page = fzip.read(os.path.join(pdir, pagename))
    tree = etree.fromstring(page, parser)
    paragraphs = tree.xpath('/xhtml:html/xhtml:body/xhtml:p', namespaces=ns)
    for p in paragraphs:
        p = split(r"(\xbb.+?\xab)", p.xpath('string()'))
        for s in p:
            s = s.strip(', .')
            if s == '':
                continue
            if s == u'\xa0':
                tasks.append(["ln", "-s", "%s/silence.wav"%cwd, "%s/%04d.wav"%(tempdir,i)])
                i+=1
                continue

            if s.startswith(u'\xbb') and s.endswith(u'\xab'):
                tasks.append(["wine", "sapi2wav.exe", "%s/%04d.wav"%(tempdir, i), "3", "-t", s])
            else:
                tasks.append(["wine", "sapi2wav.exe", "%s/%04d.wav"%(tempdir, i), "2", "-t", s])
            i+=1
            tasks.append(["ln", "-s", "%s/silence.wav"%cwd, "%s/%04d.wav"%(tempdir,i)])
            i+=1
    tasks.append(["ln", "-s", "%s/silence.wav"%cwd, "%s/%04d.wav"%(tempdir,i)])
    i+=1

wavs = ["%s/%04d.wav"%(tempdir,j) for j in range(i)]
for wav in wavs:
    if os.path.exists(wav):
        os.unlink(wav)

def worker(cmd):
    with open(os.devnull, "w") as fnull:
        subprocess.call(cmd, shell=False, stdout = fnull, stderr = fnull)
cpucount = multiprocessing.cpu_count()
cpucount = 1
pool = multiprocessing.Pool(processes=cpucount)
num_tasks = float(len(tasks))
for i,_ in enumerate(pool.imap_unordered(worker, tasks)):
    sys.stdout.write("%f\r"%(100*i/num_tasks))
    sys.stdout.flush()

p1 = subprocess.Popen(["./concatenate_wav"]+wavs, stdout=subprocess.PIPE)
p2 = subprocess.Popen(["./stride"], stdin=p1.stdout, stdout=subprocess.PIPE)
p3 = subprocess.Popen(["sox", "--show-progress", "--type", "raw", "--rate", "22050", "--encoding", "signed-integer", "--bits", "16", "--channels", "1", "-", "--rate", "22050", "--comment", "", "--compression", "0", "%s.ogg"%title, "tempo", "-s", "2.0"], stdin=p2.stdout, stdout=None)
p1.stdout.close()
p2.stdout.close()
p3.wait()

for wav in wavs:
    os.unlink(wav)
