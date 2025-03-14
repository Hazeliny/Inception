document.addEventListener("DOMContentLoaded", function() {
    console.log("Go-web loaded");

    // Add event listener to the button
    var button = document.getElementById("myButton");
    button.addEventListener("click", function() {
        alert("Remember the Neighbours");
    });
});
