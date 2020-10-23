class Dep {
    constructor() {
        this.subs = []
    }

    addSub(sub) {
        this.subs.push(sub);
    }

    removeSub() {
        for ( let i = this.subs.length - 1; i >= 0 ; i-- ) {
          if ( sub === this.subs[ i ] ) {
            this.subs.splice( i, 1 );
          }
        }
    }

    // 将当前的dep和watch进行关联
    depend() {
        if ( Dep.target ) {

          this.addSub( Dep.target ); // 将 当前的 watcher 关联到 当前的 dep 上

          Dep.target.addDep( this ); // 将当前的 dep 与 当前渲染 watcher 关联起来

        }
    }

    notify() {
        let deps = this.subs.slice();

        deps.forEach( watcher => {
          watcher.update();
        } );
    }
}

Dep.target = null

let targetStack = [];

/** 将当前操作的 watcher 存储到 全局 watcher 中, 参数 target 就是当前 watcher */
function pushTarget(target) {
    targetStack.unshift(Dep.target); // vue 的源代码中使用的是 push
    Dep.target = target;
}

/** 将 当前 watcher 踢出 */
function popTarget() {
    Dep.target = targetStack.shift(); // 踢到最后就是 undefined
}

/**
 * 在 watcher 调用 get 方法的时候, 调用 pushTarget( this )
 * 在 watcher 的 get 方法结束的时候, 调用 popTarget()
 */