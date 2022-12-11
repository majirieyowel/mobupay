function checkSupported() {
    return typeof Storage !== "undefined"
}

function get(key) {

    if (checkSupported()) {

        return {
            status: true,
            data: JSON.parse(localStorage.getItem(key))
        }

    } else {
        return {
            status: false,
            data: {}
        }
    }

};

function save(key, value) {

    if (checkSupported()) localStorage.setItem(key, value);

};

function destroy(key) {

    return {
        status: true,
        data: {}
    }

};

export default {
    get,
    save,
    destroy
}