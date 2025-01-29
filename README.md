# 📱 EVENTO 
## Event Management Mobile Application System Using Flutter

📌 Overview
The Event Management System App is a Flutter-based application designed to simplify event organization and participation. Users can log in and choose to either create an event or join an existing event using a unique code.
Mention its purpose and key features.

✨ Key Features:
Event Creation: Users can fill out a form to create an event and receive a unique event code.
Event Joining: Participants can enter an event code to RSVP and gain access to event details.
User Authentication: Secure login system for event hosts and attendees.
Seamless UI: Simple and intuitive design for easy navigation.
This app is designed to streamline the RSVP process, making event organization more efficient and hassle-free. 🚀

🛠️ Technologies Used:
<p align="center">
  <img src="readme_assets/flutter icon.png" alt="Flutter" width="60"/>
  <img src="readme_assets/dart icon.png" alt="Dart" width="60"/>
  <img src="readme_assets/firebase icon.png" alt="Firebase" width="60"/>
</p>

## 🔄 App Flowchart
This flowchart represents the overall event creation and joining process.
<p align="center">
  <img src="readme_assets/Flowchart.jpg" alt="Event Flowchart" width="80%"/>
</p>

## 📄 Pages
Below are the pages that exist in this application.

Login page: Use google sign-in as authentication to get the profile of the user
            Page image: 🖼️

Home page: User will choose whether to create event, join event, or manage event
           User will also be able to logout by pressing the logout buttton
           Page image: 🖼️

Create event page: User will need to fill the form detailing the event
                   Unique six character code will be created for people to join the event
                   Page image: 🖼️

Join event page: User will input unique six character code belonging to the event that they wanted to join
                 Page image: 🖼️

Manage event page: Display two tab which are created event tab and joined event tab
                   Created event tab display the event that are created by the the user and some details of the event
                   Joined event tab display the event that the user joined and their six character unique code
                   Page image: 🖼️

## 🚫 Restrictions & Compatibility

- 📱 **Supported Platform:** **Android only** *(iOS support is not available yet)*
- 🔢 **Minimum Android Version:** **Android 14+**
- 🚧 **Known Issue:** Users on **Android 13 and below** may face issues with login functionality.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

