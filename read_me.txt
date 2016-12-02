The Feedstock Processing Controller (Controller) uses the hardware, libraries and construction/test documentation 
from the Open Source Controller, by Bob Glicksman and Curbie (https://github.com/BobGlicksman/OpenSourceController).  
Software has been written to utilize this Controller to support feedstock processing experimentation and operations. 
The Controller monitors a process’ temperature and includes a countdown stop watch timer.  The basic processing 
functions supported are temperature and time monitoring.  The Controller is intended for use in feedstock processing 
experimentation where a batch of feedstock, with enzymes and other chemical agents added, must be cooked, i.e. held 
within a specific temperature range, for some pre-specified period of time. 

NOTE:  This project requires use of Arduino IDE version 022.  The included libraries are not supported under
Arduino IDE versions 1.x.

This repository contains files for the Feedstock Processing Controller, release package 1.1.
The repository contains the following folders and their contents:

- Documentation:  
--  Feedstock Process Controller User Manual v11: pdf version of the user manual.

- Photos:  
-- Photos of using the Feedstock Processing Controller to control and monitor temperature and process step time
--    using a Power Switch Tail to control AC power to an electric heater and a DS18B20 based temperature
--    probe to monitor temperature in a Libby stainless steel corn popper used as the cooking/processing pot.

- Software:
-- Processing_11: folder to copy to the Arduino022 "sketch" folder.

In order to use this software, you must build or otherwise obtain an Open Source Controller.  The release package for this
device is also maintained on this web site.

The Feedstock Processing Controller and the Open Source Controller, including all items in this archive, 
is released under a Creative Commons license Attribution-ShareAlike 3.0.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to Creative Commons, 
444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

The Feedstock Processing Controller and the Open Source Controller are intended for hobbyist applications and for 
“do it yourself” assembly and use. The user assumes all responsibility and liability for any damages, injuries or 
consequences resulting from the construction, implementation and use of this product or any part thereof.

Copyright © 2012 Bob Glicksman, Curbie. All rights reserved.

The material contained within this document and its archive may not be copied, duplicated, or reproduced in whole or in part using any method, 
for any reason, or under any circumstances without expressed written permission by the authors. Individuals may download and 
keep one unaltered copy for non-profit, personal use of the contents.
