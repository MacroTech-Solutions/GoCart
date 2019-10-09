# GoCart

Created by Arya Tschand, Sai Vedagiri, Joshua Rakovitsky 9/6/19-

## What it does
Our mobile app, web app, and anti-theft system provide an easy, straightforward platform for businesses to incorporate our technology and for consumers to use it.

## Inspiration
Our goal was to create a system that could improve both a shopper's experience and a business's profit margin. People waste millions of hours every year waiting in supermarket lines and businesses need to spend a significant amount of money on upkeep, staffing, and real estate for checkout lines and stations.

## How we built it
We used RFID technology and Bluetooth in conjunction with an Arduino Mega board for most of the core functions. A long-range RFID reader and controller was used for the anti-theft system. A multi-colored LED, buzzer, and speaker were used for supplementary functions.

# Usage

## iOS App (Swift, Objective-C, Ruby)
The iOS is the frontend to a user (shopper). It is written in Swift and Objective-C on Xcode. You are brought to a login/signup page which communicates with a Firebase database via sha-512 end-to-end encryption to enter and access user credentials. The user then has the option to view and edit their profile, make a shopping list, or "Shop now." As with the login/signup page, all communication in the profile page with Firebase is sha-512 encrypted and allows users to edit name, email, and password. Shopping lists can be created and stored locally, where the user can add products. All products are initially loaded from the Firebase database with their name, price, display image URL, and associated RFID tag. By storing all products locally, fewer queries are made, thus increasing efficiency of the app. Before a user can begin shopping, they must connect to the shopping cart via Bluetooth. Once connected, the user can place any recognized item in the cart and the item will display in the app. If the item is on the shopping list, it will change the color of the row and if the item is an extra, it will append to the bottom of the list. The user can pay for their items using Apple Pay, eliminating the time needed for checkout.

## Hardware (C++)
The hardware is built using Arduino. A HM-10 Bluetooth chip is connected to provide iOS compatible connection. An MFRC522 RFID reader is used to obtain the identification numbers of each tag attached to each product. The id number is sent to the iOS app via Bluetooth, where the id number is mapped to a product name, price, and display image URL. The product name and price is sent back to the Arduino through Bluetooth and displayed on a 16x2 liquid crystal display. Conversely, if an error is encountered such as "Item not found" or "Duplicate item," these errors can also be displayed on the LCD. When Bluetooth connection with the iOS app, a multicolor RGB LED illuminates blue. When an item is scanned, the LED blinks green to alert the user. If any errors occur or there is no Bluetooth connection, the LED is red. There is also a buzzer to alert the user of a scanned item. 

## Anti-Theft (Auto Hotkey, Node.js, Batch file)
The anti-theft system combines the use of a long-range reader and microcontroller with a script referring to the firebase. The Node.JS script verifies if the cart identified by the reader has been purchased. The Batch file saves the output of the script to a text document that can be read by the Auto Hotkey script. This Auto Hotkey script runs commands to specify the order of the processes taken to verify the checkout. If the cart is determined to have not been paid for, an alarm will sound, alerting administrators of the theft.

## Web App (HTML, CSS, JavaScript)
The web app is designed to allow the administrators of the organization to add products and carts to their store. The sign-in system of the webpage uses Google Sign-in, which has Google-managed security, or BCrypt encryption with self-generated salts to make the passwords practically undecodable. The web app allows the administrators to import csv files of all the inventory and carts for ease of use. It populates all the necessary information into the database for the rest of the applications to use.

## Firebase Database
Firebase is used as a backend to the iOS app and web app. Login credentials (name, email, password) for iOS app users are stored here, with password stored using sha-512 end-to-end encryption. Through the admin console, organizations can be added containing admin users, carts, and RFID keys. The admin users' data is stored using BCrypt encryption with a self-generated salt. Admin users can add items and carts to their online inventory with images, names, and prices and users can interface with on the mobile app. They also assign the unique RFID number to each item and cart. The RFID numbers are used by the iOS app to recognize products added to the cart and display the product details on the iOS and web app. The carts are also assigned an RFID number for anti-theft purposes. The reader communicates with the database every time a cart is read to cross reference its payment status and alert for potential theft. All elements of the database are assigned random identifiers, which makes it much harder for a user to break into another user's account and data.
