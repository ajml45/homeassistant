# Home Assistant Configuration

This repository contains a custom Home Assistant configuration, including automation rules, frontend themes, and custom scripts. It leverages YAML automation, advanced templating, and Home Assistant's extensibility to create an integrated and responsive environment.

## Features Used

- **YAML Automations**: Uses YAML-based automation with [Sun Triggers](https://www.home-assistant.io/docs/automation/trigger/#sun-trigger) to adjust blinds and lighting based on sunrise and sunset ([automations.yaml](./automations.yaml)).
- **Templating with Jinja2**: Dynamic values in scripts and automations utilize [Jinja2](https://jinja.palletsprojects.com/en/3.0.x/) for flexible logic ([configuration.yaml](./configuration.yaml)).
- **Asynchronous Execution**: Home Assistant's support for [async Python integrations](https://docs.python.org/3/library/asyncio.html) is leveraged in scripts for non-blocking execution.
- **Custom Lovelace UI Enhancements**: Implements [Bubble Card](https://github.com/Clooos/Bubble-Card) for interactive UI elements, including lighting and scene controls ([mobile_frontend.yaml](./mobile_frontend.yaml), [tablet_frontend.yaml](./tablet_frontend.yaml)).
- **Custom Themes and UI Styling**: Defines and overrides UI styles using YAML, including card backgrounds, typography, and animations ([mobile.yaml](./mobile.yaml), [isaaclucas_kitchen.yaml](./isaaclucas_kitchen.yaml)).

## Noteworthy Libraries and Scripts

- **[Jinja2](https://jinja.palletsprojects.com/en/3.0.x/)** – Used for templating dynamic values in automations.
- **[PyYAML](https://pyyaml.org/)** – Processes YAML configurations for Home Assistant.
- **[Voluptuous](https://github.com/alecthomas/voluptuous)** – Schema validation for configurations.
- **[Bubble Card](https://github.com/Clooos/Bubble-Card)** – A Lovelace UI component for interactive elements.
- **[Roboto](https://fonts.google.com/specimen/Roboto) & [Raleway](https://fonts.google.com/specimen/Raleway)** – Custom fonts applied in mobile and tablet views.
- **[Ashley's Light Fader](https://community.home-assistant.io/t/ashley-s-light-fader-2-0-fade-lights-and-or-color-temperature-with-your-choice-of-easing-curves-including-ease-in-ease-out-and-ease-in-out/584077)** - Gradually fades lights from current level

## Project Structure
```plaintext
.
├── automations.yaml         # Automations for blinds, lighting, and routines
├── configuration.yaml       # Core Home Assistant configuration, linking automations, scenes, and scripts
├── mobile.yaml              # Theme settings for mobile UI
├── mobile_frontend.yaml     # Lovelace UI layout for mobile devices
├── tablet_frontend.yaml     # Lovelace UI layout for tablets
├── isaaclucas_kitchen.yaml  # Custom theme for kitchen dashboards
├── scenes.yaml              # Scene presets for lighting and climate control
├── scripts.yaml             # Custom scripts for automation, including light fading
├── themes/                  # Directory for additional themes
│   ├── dark_theme.yaml      # Example theme for dark mode
│   ├── light_theme.yaml     # Example theme for light mode
│   └── ...
├── www/                     # Web assets (images, icons, and frontend scripts)
│   ├── images/              # Custom images for dashboards
│   ├── icons/               # Additional UI icons
│   ├── custom-brand-icons/  # External brand icons for UI
│   ├── lovelace-card-mod/   # JavaScript for Lovelace UI modifications
│   └── ...
└── README.md                # Documentation for the repository
```

**Description of Key Directories**
automations.yaml – Defines rules for automated actions like adjusting blinds and lights based on time or sun position.
configuration.yaml – The main configuration file that integrates automations, scripts, scenes, and UI elements.
mobile.yaml – Defines mobile-friendly UI styles, including typography and colors.
mobile_frontend.yaml – Custom Lovelace layout for mobile dashboards.
tablet_frontend.yaml – Dashboard layout optimized for tablet screens.
isaaclucas_kitchen.yaml – A separate theme for kitchen-specific UI elements.
scenes.yaml – Stores predefined home automation scenes, such as setting lighting moods.
scripts.yaml – Contains reusable automation scripts, including complex lighting transitions.
themes/ – Houses additional theme files for the Home Assistant UI.
www/ – A public directory for images, custom icons, and JavaScript enhancements.

## Light Control Info
The "Main Light" controls most of the lights in the house by creating a single light with <a href="https://github.com/fredck/lightener">Lightener</a>.  Each room of the house has its own light in Lightner that controls all lights in the room.  The main light control is made of up each of those room lights. Need to convert some integrations to MQTT in order to have better control.

## Tablet Dashboard
Home Page, dashboard uses sidecard card for the side menu.  
![1](https://github.com/user-attachments/assets/187f8ae1-4801-4873-9c52-16e8f4454f5a)

Music/Sonos Card
![2](https://github.com/user-attachments/assets/9d28daec-29e7-4228-971e-2984e95f9653)

 Main room controls. Room cards have conditional icons that display when things are active (like HVAC, fans, lights/count, motion, etc.) Tapping a room card opens a pop-up via <a href="https://github.com/Clooos/Bubble-Card">Bubble Card</a> with all of the room controls (examples below.) Double tapping opens the main light contol for that room. Holding a room card shuts off all lights in that room.
![3](https://github.com/user-attachments/assets/3744086c-4b57-4a2e-ad4c-df54ef1095a1)

Camera card for Arlo, this doesnt really work....
![4](https://github.com/user-attachments/assets/93455f21-a02e-4d66-9073-87f0cdb1445c)

Mail card from Mail and Packages, acts as a pop-up via Bubble Card.
![5](https://github.com/user-attachments/assets/c6aa938f-ddeb-4da0-a8b5-5688f33ca013)

Weather info
![6](https://github.com/user-attachments/assets/c9d42f7e-dbc8-45df-bd98-d1f62dd0c27f)

To-Do Lists
![7](https://github.com/user-attachments/assets/e27007bc-9512-43ae-bb85-3712bb8fcbba)

Room Pop-Up Example: Great Room
![8](https://github.com/user-attachments/assets/98d21714-3c3f-46c4-93e5-e45c9ed91176)

Room Pop-Up Example: Solarium
![9](https://github.com/user-attachments/assets/6714fd23-2d5e-4a87-8b51-0b7ca3e6c274)

Room Pop-Up Example: Mudroom
![10](https://github.com/user-attachments/assets/973e7d17-c7a2-46f2-a461-572a66b80eb3)

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
- Arlo Camera Support (cameras)


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

