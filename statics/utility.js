// create station list from json file
fetch("./stationList.json")
    .then(response => response.json())
    .then(data => {
        const container = document.getElementById("selection");
        data.forEach(station => {
            const article = document.createElement("article");
            const imgSrc = `./img/stations/${station.img}`;

            // if description is undefined, use name
            const description = station.description || station.name;

            // construct image tag
            const imgTag = document.createElement("img");
            imgTag.className = "station";
            imgTag.src = imgSrc;
            imgTag.alt = station.name;

            if (station.type === "radiko") {
                // .onclick requires a fucntion (overrides previous .onclick setting)
                imgTag.onclick = () => playRadiko(station.id);
            } else {
                imgTag.onclick = () => playOrdinary(station.name, station.img, station.url);
            }

            // spawn tags 
            article.appendChild(imgTag);
            article.appendChild(document.createElement("p")).textContent = description;
            container.appendChild(article);
        });
    });

const volumeBtn = document.getElementById("volume");
const volumeModal = document.getElementById("volume-modal");

// toggle volume modal when volume icon is clicked
volumeBtn.addEventListener("click", () => {
    volumeModal.classList.toggle("show");
    volumeBtn.classList.toggle("active");
});

// close volume modal when click other objects
document.addEventListener("click", (e) => {
    // nothing happens when volume modal is not active
    if (!volumeBtn.classList.contains("active"))
        return;
    // if click out of volume botton or modal
    if (!volumeBtn.contains(e.target)) {
        volumeBtn.classList.remove("active");
        volumeModal.classList.remove("show");
    }
});


const powerBtn = document.getElementById("power-button");
const powerModal = document.getElementById("power-modal");
const cancelBtn = document.querySelector("#power-modal .cancel");

// toggle power modal when power icon is clicked
powerBtn.addEventListener("click", () => {
    powerModal.classList.add("show");
});

powerModal.addEventListener("click", (e) => {
    if (e.target === powerModal) {
        powerModal.classList.remove("show");
    }
});

cancelBtn.addEventListener("click", () => {
    powerModal.classList.remove("show");
});


// update each info when page loaded
updateStatus();
getVolume();


// update now playing info
setInterval(updateStatus, 10000);

// update current volume regularly
setInterval(getVolume, 10000);
