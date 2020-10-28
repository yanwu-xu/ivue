let methods = ['push', 'pop']

function extendMethods (arr) {
    let arrayProto = Array.prototype
    let proto = Object.create(arr.__proto__)
    methods.forEach(key => {
        proto[key] = function () {
            console.log(arguments);
            var args = [], len = arguments.length;
            while ( len-- ) args[ len ] = arguments[ len ];
            console.log(111, args);
            let result = arrayProto[key].apply(this, args)
            args.forEach(item => {
                createActive(item)
            })
            return result
        }
    })
    arr.__proto__ = proto
}

function obServe(obj, key, value, vm) {
    if (Array.isArray(value)) {
        extendMethods(value)
    }

    let dep = new Dep();

    Object.defineProperty(obj, key, {
        configurable: true,
        get() {
            console.log('执行get');
            dep.depend();
            return value
        },
        set(newVal) {
            console.log('执行set');
            value = newVal
            createActive(newVal, vm)
            // vm.mountComponent()
            dep.notify();
        }
    })


}

function createActive(obj, vm) {
    if (Array.isArray(obj)) {
        obj.forEach(item => {
            createActive(item, vm)
        })
    }
    if (typeof obj === 'object' && !Array.isArray(obj)) {
        Object.keys(obj).forEach(key => {
            if (typeof obj[key] === 'object') {
                createActive(obj[key], vm)
            }
            obServe(obj, key, obj[key], vm)
        })
    }

}