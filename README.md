# HB books bulk downloader
https://github.com/mmarcincin/HB-books-bulk-downloader/archive/master.zip
----------------------
HB books bulk downloader 0.1
----------------------
It's a powershell script which allows you to download books from humble bundle pages (https://www.humblebundle.com/downloads?key=XXXXXXXXXXXXXXXX) in bulk.
It uses Internet Explorer instance to retrieve the links so all you need to do is login to humble bundle through the internet explorer and that's it.

Right now the script puts each book into its own folder and all versions inside. 
I'll add some options later, like download only some versions (pdf, epub, etc..) and maybe different folder sorting by book version instead of book name (for example, all pdf in one folder).


Powershell ExecutionPolicy change
----------------------
start RUN.bat to launch the script
for editing the script itself open HB-books_download.ps1 in notepad (or notepad++,etc...)

If the window closes fast after starting RUN.bat (or it doesn't show on startup when using that option): 
1. Go to any folder (file explorer) and choose file > open windows powershell > 
   > open windows powershell as administrator.
2. In the Windows PowerShell window type: get-ExecutionPolicy.
3. If you are geting the 'Restricted' text, type: set-ExecutionPolicy RemoteSigned,
   then just confirm with y for yes.
4. After that the RUN.bat should work as intented.

If you'd like to create a shortcut for the script, you just need to make shortcut of RUN.bat file.
