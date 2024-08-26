## Light Control Info
The "Main Light" controls most of the lights in the house by creating a single light with <a href="https://github.com/fredck/lightener">Lightener</a>.  Each room of the house has its own light in Lightner that controls all lights in the room.  The main light control is made of up each of those room lights.

Light scripting: 
- An hour before sunset the lights in the majority of the rooms transition to 45% (if they are off) over a 5 minute period.  This uses the built in Home Assistant service calls, <a href="https://everythingsmarthome.co.uk/creating-wake-up-sunrise-lights-with-home-assistant/">more details here.</a>
- Beginning at 6:30pm for the majority of rooms (some are later for example the Solarium doesnt start until 830pm), the lights gradually fade from their current brightness down to dim levels (generally 15-0% based on the room.)  This is done via <a href="https://community.home-assistant.io/t/ashley-s-light-fader-2-0-fade-lights-and-or-color-temperature-with-your-choice-of-easing-curves-including-ease-in-ease-out-and-ease-in-out/584077">Ashley's fader script."
- On Sat/Sun the lights come on an hour earlier.  On Fri/Sat they start turning off an hour later.
- The code for this is set-up in Lightener for the lights and the scripts.yaml file for the logic. </br>

Visual of how lights are set-up:![297496597-52af8497-7db8-49c9-a0ad-ab34c4bc2a5a](https://github.com/user-attachments/assets/2587f88d-cc35-48d5-a049-9b15a4c7c414) </br>


## Tablet Dashboard
</br>
Home Page, dashboard uses sidecard card for the side menu.  
![1](https://github.com/user-attachments/assets/187f8ae1-4801-4873-9c52-16e8f4454f5a)

</br>
Music/Sonos Card
![2](https://github.com/user-attachments/assets/9d28daec-29e7-4228-971e-2984e95f9653)

</br>
 Main room controls. Room cards have conditional icons that display when things are active (like HVAC, fans, lights/count, motion, etc.) Tapping a room card opens a pop-up via <a href="https://github.com/Clooos/Bubble-Card">Bubble Card</a> with all of the room controls (examples below.) Double tapping opens the main light contol for that room. Holding a room card shuts off all lights in that room.
![3](https://github.com/user-attachments/assets/3744086c-4b57-4a2e-ad4c-df54ef1095a1)

</br>
Camera card for Arlo, this doesnt really work....
![4](https://github.com/user-attachments/assets/93455f21-a02e-4d66-9073-87f0cdb1445c)

</br>
Mail card from Mail and Packages, acts as a pop-up via Bubble Card.
![5](https://github.com/user-attachments/assets/c6aa938f-ddeb-4da0-a8b5-5688f33ca013)

 </br>
Weather info
![6](https://github.com/user-attachments/assets/c9d42f7e-dbc8-45df-bd98-d1f62dd0c27f)

 </br>
To-Do Lists
![7](https://github.com/user-attachments/assets/e27007bc-9512-43ae-bb85-3712bb8fcbba)

</br>
Room Pop-Up Example: Great Room
![8](https://github.com/user-attachments/assets/98d21714-3c3f-46c4-93e5-e45c9ed91176)

 </br>
Room Pop-Up Example: Solarium
![9](https://github.com/user-attachments/assets/6714fd23-2d5e-4a87-8b51-0b7ca3e6c274)
</br>
Room Pop-Up Example: Mudroom
![10](https://github.com/user-attachments/assets/973e7d17-c7a2-46f2-a461-572a66b80eb3)
</br>
Settings etc
![11](https://github.com/user-attachments/assets/b2b11670-cf3a-461c-91b4-7a163ce16c9e)


## Mobile Dashboard
Double clicking the icon brings up the main room light and holding the icon shuts all of the lights off in that room.
![1](https://github.com/user-attachments/assets/19f89bf1-d0a1-4169-a776-d27efc63a3f2)

![2](https://github.com/user-attachments/assets/b9b41a69-c584-4262-bc85-74d1b4495456)

![3](https://github.com/user-attachments/assets/63fca55f-1142-4eb1-b39e-0a374a124fd4)

![4](https://github.com/user-attachments/assets/e0f9fb0e-7b8e-48e1-8f86-f6ce669d5e77)

![5](https://github.com/user-attachments/assets/eb6ca876-689e-42cb-887d-ac01e8d2732d)


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
