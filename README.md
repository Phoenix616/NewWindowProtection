# NewWindowProtection
Really simple AutoHotKey script to stop you from sending input for a certain amount of time after a new window opens. This is extremely helpful when while you type a new window pops up, e.g. after starting a program or because of an error alert and your input gets directly send to the new application as it steals the focus. 

Why AutoHotkey you might ask. Well I'm familiar with using keyboard stuff under windows with it and it was the fastest thing for me to get up and running.

You need [AutoHotkey](https://autohotkey.com/) installed if you don't want to run random executables from the web!

### NewWindowProtection.ini
``` ini
[Settings]
filelog=0
; Log everything to file
notifications=1
; Show tray tip when steal was blocked
inputonly=1
; Only stop stealing when keyboard typing is detected
preventinput=1000
; Number of milliseconds in which we should prevent input in newly created windows
```

### License:

> Copyright (C) 2016 Max Lee (https://github.com/Phoenix616/)

> This program is free software: you can redistribute it and/or modify
> it under the terms of the Mozilla Public License as published by
> the Mozilla Foundation, version 2.

> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> Mozilla Public License v2.0 for more details.

> You should have received a copy of the Mozilla Public License v2.0
> along with this program. If not, see <http://mozilla.org/MPL/2.0/>.
