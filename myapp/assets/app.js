
function createEvent(type, data) {
    return new CustomEvent(type, { detail: data });
}

var plugins = (function () {
    console.log('hello plugin!');
    function _invokeMobileApp(api, data, successCallback, errorCallback) {
        console.log('invokeMobileApp, ', api, JSON.stringify(data));
        successCallbacks[api] = successCallback;
        errorCallbacks[api] = errorCallback;
        data = JSON.stringify({
            api: api,
            data: data || {},
        });
        MobileApp.postMessage(data);
        console.log('done _invokeMobileApp, ', api, data);
    }
    function _receiveMessage(msg) {
        console.log('receiveMessage, ', JSON.stringify(msg));
        if (successCallbacks[msg.api]) {
            if (!!msg.data.resp) {
                console.log('SUCCESS');
                successCallbacks[msg.api](JSON.parse(msg.data.resp));
            }
            else {
                console.log('ERROR');
                try {
                    errorCallbacks[msg.api](JSON.parse(msg.data.resp));
                } catch (e) {
                    errorCallbacks[msg.api]();
                }
            }
        }
    }
    function _isAvailable(successCallback, errorCallback) {
        _invokeMobileApp('isavailable', {}, successCallback, errorCallback);
    }
    function _save(key, password, successCallback, errorCallback) {
        var value = JSON.parse(password);
        var data = { 'key': key, value };
        _invokeMobileApp("setvalue", data, successCallback, errorCallback);
    }
    function _verify(key, message, successCallback, errorCallback) {
        var data = { 'key': key, 'usermessage': message };
        _invokeMobileApp('verify', data, successCallback, errorCallback);
    }
    function _has(key, successCallback, errorCallback) {
        var data = { 'key': key };
        _invokeMobileApp('has', data, successCallback, errorCallback);
    }
    function _delete(key, successCallback, errorCallback) {
        var data = { 'key': key };
        _invokeMobileApp('delete', data, successCallback, errorCallback);
    }
    var successCallbacks = {};
    var errorCallbacks = {};
    return {
        fingerprint: {
            receiveMessage: function (msg) {
                _receiveMessage(msg);
            },
            isAvailable: function (successCallback, errorCallback) {
                _isAvailable(successCallback, errorCallback);
            },
            save: function (key, password, successCallback, errorCallback) {
                _save(key, password, successCallback, errorCallback);
            },
            verify: function (key, message, successCallback, errorCallback) {
                _verify(key, message, successCallback, errorCallback);
            },
            has: function (key, successCallback, errorCallback) {
                _has(key, successCallback, errorCallback);
            },
            delete: function (key, successCallback, errorCallback) {
                _delete(key, successCallback, errorCallback);
            }
        }
    }
})();
