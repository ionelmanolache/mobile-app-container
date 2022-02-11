plugins = {};
plugins.fingerprint = {};

plugins.fingerprint.isAvailable = function (successCallback, errorCallback) {
    //MobileApp.exec("isAvailable");
    console.log('isAvailable');
    if (true) {
        successCallback();
    } else {
        errorCallback();
    }
}

function invokeMobileApp(data) {
    MobileApp.postMessage(data);
}

window.plugins.fingerprint.isAvailable(function () {
    console.log('isAvailable=TRUE');
}, function () {
    console.log('isAvailable=FALSE');
});

window.document.addEventListener("deviceready", function (e) {
    console.log('EVENT deviceready, e.detail=', JSON.stringify(e.detail));
});

function createEvent(type, data) {
    return new CustomEvent(type, { detail: data });
}

function startLogin() {
    window.document.loginForm.submit();
}

function validateLoginForm() {
    window.document.getElementById("loginButton").disabled = !window.document.loginForm.userName.value || !window.document.loginForm.userPassword.value;
}