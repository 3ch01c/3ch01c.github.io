# How to use ESP8266 boards with Arduino

<img src="https://user-images.githubusercontent.com/5547581/203403597-b7ae8942-6d4b-47c7-bd13-0cdd7574c3e2.png" alt="nodemcu amica esp8266 board" height="400"/>

1. Download the Arduino IDE [v1](https://docs.arduino.cc/software/ide-v1) or [v2](https://docs.arduino.cc/software/ide-v2). I'm using 1.8 on Windows.

2. If it's CP210x chip, download the universal drivers from [here](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers?tab=downloads). Unzip, then plug in your board, and then choose _Update Driver_ when it prompts you to install a driver. Point it to the unzipped directory.

3. Open Arduino IDE, go to _File_ > _Preferences_ > _Additional Board Manager URLs_ and add https://arduino.esp8266.com/stable/package_esp8266com_index.json.

4. Go to _Tools_ > _Board_ > _ESP8266 Boards_ > _NodeMCU 1.0 (ESP-12E Module)_.

5. Set the right port. For me, it's COM5.

6. Configure the baud rate. For me, it's 9600.
