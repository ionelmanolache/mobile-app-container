var plugins = (function () {
    function test() { }
    function invokeMobileApp(data) {
        MobileApp.postMessage(data);
    }
    return {
        fingerprint: {
            currentRequest: "",
            currentSuccessCallback: null, 
            currentErrorCallback: null,
           
            isAvailable: function (successCallback, errorCallback) {
                invokeMobileApp("isAvailable");
                this.currentRequest = "isAvailable";
                this.currentSuccessCallback = successCallback;
                this.currentErrorCallback = errorCallback;
                count=0;
                do {
                    setTimeout(function () {count++;}, 100);
                  } while (count < 5);
                
            },
            save: function (key, password, successCallback, errorCallback) {
                invokeMobileApp("save;password");
            },
            verify: function (key, message, successCallback, errorCallback) {
                invokeMobileApp("verify;message");
            },
            has: function (key, successCallback, errorCallback) {
                invokeMobileApp("has");
            },
            delete: function (key, successCallback, errorCallback) {
                invokeMobileApp("delete");
            },
            resp: function (m, detail) {
                this.currentRequest = "_"+m;
                this.currentResponse = 
                this.currentSuccessCallback;
                this.currentErrorCallback = errorCallback;
            }
        }
    }
})();

window.document.addEventListener("deviceready", function (e) {
    console.log('EVENT deviceready, e.detail=', JSON.stringify(e.detail));
    window.plugins.fingerprint.setBioSensor(e.detail.hasBioSensor);
});

function createEvent(type, data) {
    return new CustomEvent(type, { detail: data });
}

//==============================================================
//==============================================================



function startLogin() {
    window.document.loginForm.submit();
}

function validateLoginForm() {
    window.document.getElementById("loginButton").disabled = !window.document.loginForm.userName.value || !window.document.loginForm.userPassword.value;
}