# Usage

Connect to your server and clone this repository via `git clone git@github.com:btmnk/vrising-docker.git`.
Run `docker compose up` and wait for ~2-3 minutes until you see something like the following:

```sh
0144:fixme:kernelbase:AppPolicyGetThreadInitializationType FFFFFFFFFFFFFFFA, 000000007292FF50
0024:fixme:nls:GetFileMUIPath stub: 0x10, L"C:\\windows\\system32\\tzres.dll", (null), 000000000010CD08, 000000006CC85800, 000000000010CD00, 000000000010CCA0
0024:fixme:nls:GetFileMUIPath stub: 0x10, L"C:\\windows\\system32\\tzres.dll", (null), 000000000010CD08, 000000006CC85800, 000000000010CD00, 000000000010CCA0
0024:fixme:nls:GetFileMUIPath stub: 0x10, L"C:\\windows\\system32\\tzres.dll", (null), 000000000010CD08, 000000006CC85800, 000000000010CD00, 000000000010CCA0
014c:fixme:kernelbase:AppPolicyGetThreadInitializationType FFFFFFFFFFFFFFFA, 0000000072B2FF50
0024:fixme:file:NtLockFile I/O completion on lock not implemented yet
0158:fixme:file:NtLockFile I/O completion on lock not implemented yet
0158:fixme:process:SetProcessShutdownParameters (00000100, 00000001): partial stub.
0024:fixme:file:CopyFileExW cancel_ptr is not supported
0130:fixme:cryptnet:check_ocsp_response_info check responder id
```

Unfortunately the output doesn't properly tell you when the server is up and running.

After the server started once it will have downloaded the latest vrising server files into `/server`, save data into `/data` and a copy of the server settings into `/settings`.

Only edit the settings files in `/settings`, they will be copied to the actual server data when starting the server. \
You will have to restart the server after changing settings.
