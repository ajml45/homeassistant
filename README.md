## Light Control Info
The "Main Light" controls most of the lights in the house by creating a single light with <a href="https://github.com/fredck/lightener">Lightener</a>.  Each room of the house has its own light in Lightner that controls all lights in the room.  The main light control is made of up each of those room lights.

Light scripting: 
- An hour before sunset the lights in the majority of the rooms transition to 45% (if they are off) over a 5 minute period.  This uses the built in Home Assistant service calls, <a href="https://everythingsmarthome.co.uk/creating-wake-up-sunrise-lights-with-home-assistant/">more details here.</a>
- Beginning at 6:30pm for the majority of rooms (some are later for example the Solarium doesnt start until 830pm), the lights gradually fade from their current brightness down to dim levels (generally 15-0% based on the room.)  This is done via <a href="https://community.home-assistant.io/t/ashley-s-light-fader-2-0-fade-lights-and-or-color-temperature-with-your-choice-of-easing-curves-including-ease-in-ease-out-and-ease-in-out/584077">Ashley's fader script."
- On Sat/Sun the lights come on an hour earlier.  On Fri/Sat they start turning off an hour later.
- The code for this is set-up in Lightener for the lights and the scripts.yaml file for the logic. </br>

Visual of how lights are set-up:
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/52af8497-7db8-49c9-a0ad-ab34c4bc2a5a)" width="200"> </br>


## Tablet Dashboard
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/577ee7d9-625c-437d-8507-37034901e044)" width="500"> </br>
Home Page, dashboard uses sidecard card for the side menu.  

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/8cc29432-8e3c-47ff-bbdb-166d2cc39929" width="500"> </br>
Music/Sonos Card

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/fdba8359-945a-45d5-b7e7-e0b41675f634" width="500"> </br>
 Main room controls. Room cards have conditional icons that display when things are active (like HVAC, fans, lights/count, motion, etc.) Tapping a room card opens a pop-up via <a href="https://github.com/Clooos/Bubble-Card">Bubble Card</a> with all of the room controls (examples below.) Double tapping opens the main light contol for that room. Holding a room card shuts off all lights in that room.

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/293c19e8-cdc1-485c-810d-587b5ffe3bbb" width="500"> </br>
Camera card for Arlo, this doesnt really work....

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/87130093-16dc-447c-8c87-c7c74b40f856" width="500"> </br>
Mail card from Mail and Packages, acts as a pop-up via Bubble Card.

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/5c282444-dc7c-452f-ad23-653c420d9064" width="500"> </br>
Weather info

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/138484a6-f9b7-444a-a2e1-8b9807286a8d" width="500"> </br>
To-Do Lists

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/f899ef67-5bf8-4dda-82c2-6e8e8c995c6a" width="500"> </br>
Room Pop-Up Example: Great Room

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/1ab8bb35-f44e-4872-9445-59046fd7cf03" width="500"> </br>
Room Pop-Up Example: Solarium

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/61576f02-0cbc-40e9-95b1-608dc5b50dcc" width="500"> </br>
Room Pop-Up Example: Mudroom

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/6a5b588f-a437-4203-8851-3cacc3f50c73" width="500"> </br>
Settings etc


## Mobile Dashboard
Uses bubble card heavily - for the home page room controls as well as the individual room pop-up cards and bottom navigation.  The room buttons on the home page are a light slider that toggle the lights for that room.  Clicking the icon brings up the room pop-up with the individual controls.  Double clicking the icon brings up the main room light and holding the icon shuts all of the lights off in that room.

<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/1ec24e7c-3f73-4170-963e-5eaeb134ff21" width="300" alt="Home Page">
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/d8c1aede-17fd-42d6-a204-04499e38bc3f" width="300" alt="Solarium">
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/4b234a66-b956-47bd-9c3d-d0e58170d58b" width="300" alt="Basement">
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/fbcca4e8-0fee-4ea2-8179-dfb592f3e13d" width="300" alt="Sonos">
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/dd4a7a4f-1d4e-424c-a773-a25f5c7e8c45" width="300" alt="Calendar">
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/362b40a5-c376-46f4-83e4-d8294d33ae42" width="300" alt="Weather">
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/9dcbb1de-ee69-4cb3-84a8-bf7998ea29dd" width="300" alt="Family">
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/476d5a2b-0a2f-473d-abb7-ea72f10baf7d" width="300" alt="IT">


## HACS Integrations:
- <a href="https://github.com/fredck/lightener">Lightener (used heavily for main light and room lights)</a>
- Mail and Packages (mail)
- iCloud3 Device Tracker (waze distances)
- SmartThinQ LGE Sensors (washer/dryer)
- Frigate (camera playback)
- Alexa Media Player (alexa integration)
- WebRTC Camera (camera playback)
- HACS
- Arlo Camera Support (cameras)
- Govee (light brand integration)
- Rollease Acmeda Autom Pulse Hub v2 (shade integration)


## HACS Frontend
- <a href="https://github.com/Clooos/Bubble-Card">Bubble Card (used heavily, for menus and pop-ups)</a>
- slider-entity-row
- Hourly Weather Card
- Stack In Card
- Sonos Card
- Clock Weather Card
- Lovelace Hass Aarlo
- mini-graph-card
- Big Slider Card
- Vacuum Card
- card-mod
- Horizon Card
- Mushroom
- layout-card
- Weather Radar Card
- Frigate Card
- Slider Button Card
- Atomic Calendar Revive
- fold-entity-row
- vertical stack in card
- Custom Brand Icons
- button-card
- Mail and Packages Custom Card
- Sidebar Card (Tablet side bar)
- Battery Entity Row
- apexcharts-card


## Integrations
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/8323707a-0f49-44c6-b1f5-4daaf6bbd619" width="800">

## Add-Ons
<img src="https://github.com/ajml45/homeassistant_configs/assets/122765092/a9e52e9a-e266-4cf4-81f0-df3efe80aa87" width="800">
