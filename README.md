# mvconvert
Meveo to Vlang module converter

To convert a meveo module, install the mvconvert module  
```
v install smichea.mvconvert
```

open a terminal in the root directory of your module and run the conversion tool

in windows
```
v show smichea.mvconvert | Select-String 'Location: (.+)' | ForEach-Object { v run ($_.Matches[0].Groups[1].Value) + '\.' }
```

in linux
```
v run $(v show smichea.mvconvert | grep 'Location:' | awk '{print $2}')/.
```

this will create the Vlang module in the `./facets/v`
