const volumeBtn = document.getElementById('volume');
const volumeModal = document.getElementById('volume-modal');

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


const powerBtn = document.getElementById('power-button');
const powerModal = document.getElementById('power-modal');
const cancelBtn = document.querySelector('#power-modal .cancel');

// toggle power modal when power icon is clicked
powerBtn.addEventListener("click", () => {
    powerModal.classList.add('show');
});

powerModal.addEventListener("click", (e) => {
    if (e.target === powerModal) {
        powerModal.classList.remove('show');
    }
});

cancelBtn.addEventListener("click", () => {
    powerModal.classList.remove('show');
});


// update each info when page loaded
updateStatus();
getVolume();


// update now playing info every 5secs and when page loaded
setInterval(updateStatus, 5000);

// update current volume regularly
setInterval(getVolume, 5000);
