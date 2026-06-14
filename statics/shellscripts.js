const status = document.getElementById("status");
const currentVolume = document.getElementById("current-volume");
const currentStation = document.getElementById("current-station");
const defaultIcon = "default";

// controller to call toggle and stop.sh
function controller(scriptName) {
    // const status = document.getElementById("status");
    status.innerText = "Processing: " + scriptName + "...";
    fetch("/cgi-bin/" + scriptName + ".sh")
        .then(response => response.text())
        .then(data => { status.innerText = "Done: " + data; })
        .catch(error => { status.innerText = "Error: " + error; });
    
    if (scriptName === "stop") {
        currentStation.src = "./img/stations/" + defaultIcon;
    }
}

// call radiko.sh with station ID
function playRadiko(name, icon, id) {
    // const status = document.getElementById("status");
    const targetRadiko = `/cgi-bin/radiko.sh?name=${encodeURIComponent(name)}&icon=${encodeURIComponent(icon)}&id=${encodeURIComponent(id)}`
    status.innerText = "Connecting to Radiko: " + name + "...";

    // pass URL to shell
    fetch(targetRadiko)
        .then(response => response.text())
        .then(data => { status.innerText = data + "Playing Radiko: " + name })
        .catch(error => { status.innerText = "Error: " + error; });
}

// call play-ordinary.sh with URL
function playOrdinary(name, icon, url) {
    // const status = document.getElementById("status");
    status.innerText = "Loading Stream: " + name + "...";
    const targetUrl = `/cgi-bin/play-ordinary.sh?url=${encodeURIComponent(url)}&name=${encodeURIComponent(name)}&icon=${encodeURIComponent(icon)}`; 
    // encodeURIComponent converts words like &? into understandable style
    fetch(targetUrl)
        .then(response => response.text())
        .then(data => {
            status.innerText = "Playing Stream: " + name; 
            updateStatus();
        })
        .catch(error => {
            status.innerText = "Error: " + error;
        });
}

// get volume value
function getVolume() {
    fetch("/cgi-bin/get-volume.sh")
        .then(response => response.text())
        .then(data => { currentVolume.innerText = data; })
        .catch(error => { status.innerText = "Error: " + error; });     
}

// set volume using volume modal
function setVolume(value) {
    const val = value.innerText;
    fetch(`cgi-bin/set-volume.sh?vol=${val}`)
        .then(getVolume);
}


// update now playing info
function updateStatus() {
    const nowInfo = document.getElementById("nowInfo")
    const wave = document.getElementById("wave-bg");

    // update letters
    fetch("/cgi-bin/nowplaying.sh")
        .then(response => response.text())
        .then(data => nowInfo.innerText = data)
        .catch(error => status.innerText = "Error:" + error);

    //update station img
    fetch("/cgi-bin/get-icon.sh")
        .then(response => response.text())
        .then(data => {
            console.log("Icon Response: " + data);
            currentStation.src = `./img/stations/${data.trim()}`;
            wave.classList.add("playing");

            if (data.trim() === "Stopped" || data.trim() === "default") {
                wave.classList.remove("playing");
                currentStation.src = "./img/stations/" + defaultIcon;
            }
        })
        .catch( () => {
            // fail safe
            currentStation.src = "./img/stations/" + defaultIcon
        });
}


function powerControl(select) {
    const powerMessage = document.getElementById("power-message");
    const byeMessage = powerMessage.firstElementChild;

    if (select === "shutdown") {
        byeMessage.innerText =
        `Shutting down...
        Wake me up later!`;
    } else if (select === "reboot") {
        byeMessage.innerText =
        `Rebooting...
        See you soon!`;
    }

    fetch("/cgi-bin/stop.sh");

    fetch("/cgi-bin/" + select + ".sh")
        .then(powerMessage.classList.add("show"))
        .catch(error => status.innerText = "Error: " + error);
}
