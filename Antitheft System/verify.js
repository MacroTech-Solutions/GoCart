let myVar = process.argv[2];

// Firebase App (the core Firebase SDK) is always required and
// must be listed before other Firebase SDKs
var firebase = require("firebase/app");

// Add the Firebase products that you want to use
require("firebase/database");

var firebaseConfig = {
    apiKey: "AIzaSyCC5RzjEekrY6bZT83_X57Dq4gpNAZPbb4",
    authDomain: "simple-shopping-c016c.firebaseapp.com",
    databaseURL: "https://simple-shopping-c016c.firebaseio.com",
    projectId: "simple-shopping-c016c",
    storageBucket: "simple-shopping-c016c.appspot.com",
    messagingSenderId: "1080608411205",
    appId: "1:1080608411205:web:cffdb36bb587d2c4911d2c"
};
// Initialize Firebase
firebase.initializeApp(firebaseConfig);

var database = firebase.database();

function checkCarts(){
    if (myVar.includes("Card NO: ")) {
        myVar = myVar.substring(9).trim();
        submit();
    } else if(/\d/.test(myVar.charAt(0))){
        myVar = myVar.trim();
        submit();
    }
}

async function submit() {
    var ref = firebase.database().ref("carts");
    let purchased;
    await ref.once("value")
        .then(function (snapshot) {
            for (key in snapshot.val()) {
                if (snapshot.val()[key].rfidTag == myVar) {
                    purchased = snapshot.val()[key]["purchased"];
                }
            }
        });
    if (!purchased) {
        console.log("Not purchased");
    } else {
        console.log("Purchased")
    }
}

checkCarts();