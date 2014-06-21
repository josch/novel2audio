{
    SAPI2Wav. Command line "Text to Speech" to Wav file using MS SAPI.
    Copyright (C) 2008  Dan Faerch

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

    Contact author at sapi2wav.dan [at] hacker.dk
}

unit ttswav;

interface

uses
//  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
//  Dialogs, StdCtrls, OleServer, SpeechLib_TLB;
  Windows, SysUtils, Forms,
  OleServer, SpeechLib_TLB, Classes;

type
  TMainForm = class(TForm)
    SpVoice1: TSpVoice;
    SpFileStream: TSpFileStream;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}


Function LoadFileToString(FileN: String):string;
var
 ProgFile, FSize:  Cardinal;
 Buff:             array[0..63999] of Char;
begin
     Result := '';

     if GetFileAttributesA(PChar(FileN)) = $FFFFFFFF then Exit;


     try
       ProgFile := CreateFile(PChar(FileN), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
       if ProgFile <> INVALID_HANDLE_VALUE then
           begin
                FileSeek(ProgFile, 0, 0);

                repeat
                      FillChar(Buff, SizeOf(Buff), 0);
                      ReadFile(ProgFile, Buff, SizeOf(Buff), FSize, nil);
                      if FSize > 0 then
                          Result := Result + Buff;
                until (FSize = 0);

                CloseHandle(ProgFile);
           end;
     Except
       //  do stuff..
     end;
end;




//------------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);
  var filename   : string;
      text       : string;
      bool       : boolean;
      mode       : string;
      i          : integer;

      Voice : ISpeechObjectToken;
      Voices: IspeechObjectTokens;
begin
    MainForm.Height := 0;
    MainForm.Width  := 0;


    Voices := SpVoice1.GetVoices('','');
    if (ParamStr(1) = '-list') then
    begin
          for i := 0 to Voices.Count - 1 do
          begin
              writeln(inttostr(i+1)+': '+Voices.Item(i).GetDescription(0));
          end;
          Application.Terminate;          
          exit;
    end;


    if ParamCount < 4 then
    begin
        writeln('Usage:');
        writeln('  sapi2wav.exe <outwave filename> <voice nr> -f <input text filename>');
        writeln('  sapi2wav.exe <outwave filename> <voice nr> -t "<text to speak>"');
        writeln('');
        writeln('Arguments:');
        writeln('  -list        List voices and the number');
        writeln('  -t           Text to read out loud. Use quotes!');
        writeln('  -f           filename of textfile to read out loud. Use either no quotes or double qoutes!');
        writeln('  ');
        writeln('Examples:');
        writeln('  sapi2wav.exe c:\out.wav 1 -t "Hellow world"');
        writeln('  sapi2wav.exe readin.wav 3 -f my_data.txt');
        Application.Terminate;
        exit;
    end;

    //Check if filename is given
    filename    := ParamStr(1);
    bool        := true;

    if length(filename)<5 then
    begin
        bool    := false;
    end;

    if (copy(filename,length(filename)-3,4) <> '.wav') then
    begin
         bool:=false;
    end;

    if (not bool) then
    begin
        writeln('Filename is the first argument given and MUST end on ".wav"');
        Application.Terminate;
        exit;
    end;

    //-----------------
    //Voice number arg
    if (strtoint(ParamStr(2))>Voices.Count) then
    begin
          writeln('Unknown voice.nr.');
          Application.Terminate;
          exit;
    end;

    Voice := ISpeechObjectToken(Voices.Item(strtoint(ParamStr(2))-1));
    writeln('Choosing voice '+ParamStr(2)+' - '+Voice.GetDescription(0));
    SpVoice1.Voice := Voice;

    //-------------------
    //Get mode arg.
    mode := ParamStr(3);

    if (copy(mode,1,1) <> '-') then bool:=false;
    mode := copy(mode,2,1);
    if (bool) then
        if ( (copy(mode,1,1) <> 't') AND (copy(mode,1,1) <> 'f') ) then bool:=false;

    if (not bool) then
    begin
        writeln('3rd arg most be -t "<text>" or -f <filename>');
        Application.Terminate;
        exit;
    end;

    //------------------    
    //Get text/filename
    text := ParamStr(4);

    if (mode = 'f') then
    if FileExists(text) then
              text := LoadFileToString(text)
    else
    begin
            writeln('File not found: '+text);
            Application.Terminate;
            exit;
    end;


    //Set wave format
//   SpFileStream.Format.type_ := SAFT22kHz16BitMono;
   SpFileStream.Format.type_ := SAFT44kHz16BitMono;

   //Open wavefile
   SpFileStream.Open(filename,SSFMCreateForWrite, False);

   //Hook wavefile to speak output.
   SpVoice1.AudioOutputStream := SpFileStream.DefaultInterface;

   //Talk
   //SVSFIsFilename
//   if (mode = 'f') then
//   SpVoice1.Speak(text, SVSFDefault or SVSFIsFilename)
//   else
   SpVoice1.Speak(text, SVSFDefault);

   SpVoice1.WaitUntilDone(-1);

   SpFileStream.Close;
   Application.Terminate;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
Application.Terminate;
end;

end.
