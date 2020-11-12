## vue的生命周期
```js
// /core/instance/init.js
  initLifecycle(vm)
  initEvents(vm)
  initRender(vm)
  callHook(vm, 'beforeCreate')
  initInjections(vm)
  initState(vm)
  initProvide(vm)
  callHook(vm, 'created')
  // 在init函数中
  vm.$mount(vm.$options.el)     // 去挂载dom
```
在 `$mount` 中执行 `mountComponent` 函数

```js
// /core/instance/lifecycle.js
mountComponent () {
  callHook(vm, 'beforeMount')

  updateComponent = () => {
    vm._update(vm._render(), hydrating)
  }

  new Watcher(vm, updateComponent, noop, {
    before () {
      if (vm._isMounted && !vm._isDestroyed) {
        callHook(vm, 'beforeUpdate')
      }
    }
  }, true /* isRenderWatcher */)

  callHook(vm, 'mounted')
}
```
在 `_update` 中执行 `vm.__patch__` 获取 `$el`， `vm.__patch__` 通过 `createPatchFunction` 得到
##### /core/vdom/patch.js
`patch` 函数中如果是首次判断 `oldVnode` `const isRealElement = isDef(oldVnode.nodeType)` 如果 `isRealElement = true` 则 `oldVnode` 为首次，则直接调用 `createElm`，如果 `isRealElement = false && sameVnode(oldVnode, vnode)` 则进行补丁操作 `patchVnode`<br/>
`patchVnode` 函数如果新老节点都是静态节点且 `key` 相同，则直接 `vnode.componentInstance = oldVnode.componentInstance`<br/>
如果是不相同的节点，则执行 `cbs.update` 去更新节点，如果都有子节点则执行 `updateChildren` 进行递归操作更新子节点，如果新的有子节点旧的没有子节点，则直接添加子节点，如果新的没有字节点旧的有子节点，则直接移除字节点。<br/>
`updateChildren` 函数
```js
function updateChildren (parentElm, oldCh, newCh, insertedVnodeQueue, removeOnly) {
  let oldStartIdx = 0
  let newStartIdx = 0
  let oldEndIdx = oldCh.length - 1
  let oldStartVnode = oldCh[0]
  let oldEndVnode = oldCh[oldEndIdx]
  let newEndIdx = newCh.length - 1
  let newStartVnode = newCh[0]
  let newEndVnode = newCh[newEndIdx]
  let oldKeyToIdx, idxInOld, vnodeToMove, refElm

  // removeOnly is a special flag used only by <transition-group>
  // to ensure removed elements stay in correct relative positions
  // during leaving transitions
  const canMove = !removeOnly

  if (process.env.NODE_ENV !== 'production') {
    checkDuplicateKeys(newCh)
  }

  while (oldStartIdx <= oldEndIdx && newStartIdx <= newEndIdx) {
    if (isUndef(oldStartVnode)) {
      oldStartVnode = oldCh[++oldStartIdx] // Vnode has been moved left
    } else if (isUndef(oldEndVnode)) {
      oldEndVnode = oldCh[--oldEndIdx]
    } else if (sameVnode(oldStartVnode, newStartVnode)) {
      patchVnode(oldStartVnode, newStartVnode, insertedVnodeQueue, newCh, newStartIdx)
      oldStartVnode = oldCh[++oldStartIdx]
      newStartVnode = newCh[++newStartIdx]
    } else if (sameVnode(oldEndVnode, newEndVnode)) {
      patchVnode(oldEndVnode, newEndVnode, insertedVnodeQueue, newCh, newEndIdx, '',true)
      oldEndVnode = oldCh[--oldEndIdx]
      newEndVnode = newCh[--newEndIdx]
    } else if (sameVnode(oldStartVnode, newEndVnode)) { // Vnode moved right
      patchVnode(oldStartVnode, newEndVnode, insertedVnodeQueue, newCh, newEndIdx)
      canMove && nodeOps.insertBefore(parentElm, oldStartVnode.elm, nodeOps.nextSibling(oldEndVnode.elm))
      oldStartVnode = oldCh[++oldStartIdx]
      newEndVnode = newCh[--newEndIdx]
    } else if (sameVnode(oldEndVnode, newStartVnode)) { // Vnode moved left
      patchVnode(oldEndVnode, newStartVnode, insertedVnodeQueue, newCh, newStartIdx)
      canMove && nodeOps.insertBefore(parentElm, oldEndVnode.elm, oldStartVnode.elm)
      oldEndVnode = oldCh[--oldEndIdx]
      newStartVnode = newCh[++newStartIdx]
    } else {
      if (isUndef(oldKeyToIdx)) oldKeyToIdx = createKeyToOldIdx(oldCh, oldStartIdx, oldEndIdx)
      idxInOld = isDef(newStartVnode.key)
        ? oldKeyToIdx[newStartVnode.key]
        : findIdxInOld(newStartVnode, oldCh, oldStartIdx, oldEndIdx)
      if (isUndef(idxInOld)) { // New element
        createElm(newStartVnode, insertedVnodeQueue, parentElm, oldStartVnode.elm, false, newCh, newStartIdx)
      } else {
        vnodeToMove = oldCh[idxInOld]
        if (sameVnode(vnodeToMove, newStartVnode)) {
          patchVnode(vnodeToMove, newStartVnode, insertedVnodeQueue, newCh, newStartIdx)
          oldCh[idxInOld] = undefined
          canMove && nodeOps.insertBefore(parentElm, vnodeToMove.elm, oldStartVnode.elm)
        } else {
          // same key but different element. treat as new element
          createElm(newStartVnode, insertedVnodeQueue, parentElm, oldStartVnode.elm, false, newCh, newStartIdx)
        }
      }
      newStartVnode = newCh[++newStartIdx]
    }
  }
  if (oldStartIdx > oldEndIdx) {
    refElm = isUndef(newCh[newEndIdx + 1]) ? null : newCh[newEndIdx + 1].elm
    addVnodes(parentElm, refElm, newCh, newStartIdx, newEndIdx, insertedVnodeQueue)
  } else if (newStartIdx > newEndIdx) {
    removeVnodes(oldCh, oldStartIdx, oldEndIdx)
  }
}
```




##### 判断两个VNode是否相等
```js
function sameVnode (a, b) {
  return (
    a.key === b.key && (
      (
        a.tag === b.tag &&
        a.isComment === b.isComment &&
        isDef(a.data) === isDef(b.data) && // 都有data 或都没有data
        sameInputType(a, b) // 如果是输入框，则需要相同的 输入框 type
      ) || (
        isTrue(a.isAsyncPlaceholder) &&
        a.asyncFactory === b.asyncFactory &&
        isUndef(b.asyncFactory.error)
      )
    )
  )
}
```

### /platforms/web/entry-runtime-with-compiler.js
对 `Vue` 重写 `$mount` 方法<br/>
`mount` 方法，先获取 `Vue.prototype.$mount` 方法，重写 `$mount` 方法<br/>
通过 `el` 或 `template` 的 `innerHTML` 或 `outerHTML` 方法获取到 `template` 模板字符串，`template` 可能是 `#app` 或 `DOM` 值，会进行判断，最后再执行 `mount`。<br/>
获取到 `template` 后通过 `compileToFunctions` 获取到 `render` 函数添加到 `this.$options` 上

### 获取AST
```json
{
  attrs: Array(1)
      0: {name: "id", value: ""app"", dynamic: undefined, start: 5, end: 13}
  attrsList: Array(1)
      0: {name: "id", value: "app", start: 5, end: 13}
  attrsMap: {id: "app"}
  children: Array(7)
      0: {type: 1, tag: "div", attrsList: Array(0), attrsMap: {…}, rawAttrsMap: {…}, …}
      1: {type: 3, text: " ", start: 63, end: 70}
      2: {type: 1, tag: "div", attrsList: Array(0), attrsMap: {…}, rawAttrsMap: {…}, …}
      3: {type: 3, text: " ", start: 104, end: 111}
      4: {type: 1, tag: "span", attrsList: Array(0), attrsMap: {…}, rawAttrsMap: {…}, …}
      5: {type: 3, text: " ", start: 175, end: 182}
      6: {type: 1, tag: "button", attrsList: Array(1), attrsMap: {…}, rawAttrsMap: {…}, …}
  end: 247
  parent: undefined
  plain: false
  rawAttrsMap:
      id: {name: "id", value: "app", start: 5, end: 13}
  start: 0
  tag: "div"
  type: 1
}
```
- compileToFunctions函数执行   /platforms/web/entry-runtime-with-compiler.js
- parse函数执行                /compiler/parser/index.js
- parseHTML函数执行            /compiler/parser/html-parser.js
执行 `parseHTML` 方法解析 `template` <br/>
判断 `template` 是否已 `<` 开头，是则表示目前是开始或结束标签或者注释，否则表示是文本类标签中的内容<br/>
通过正则表达式判断是开始标签还是结束标签<br/>
开始标签获取标签名，通过正则获取属性并创建 `attrs` 数组用于存放对象，添加 `start end` 属性<br/>
结束标签会去执行 `closeElement` 方法，会有一个变量存储所有之前解析过的标签，（类似于执行栈的后进先出和koa执行中间件的洋葱模型），最后一个元素就是目前这个结束标签的开始标签，倒数第二个元素是目前标签的父标签。获取到开始标签和父标签之后在变量中移除这两个元素，并将父标签放到目前标签的 `parent` 元素中，将目前的标签放入到父标签的 `children` 标签中<br/>
文本类型获取文本的内容，放入到目前的标签元素中，可能 `type = 2` 或 `type = 3`<br/>
`advance` 函数管理 `index` 和 `html(template)` ，根据匹配到的内容从头部一点点减去 `html` 的内容，知道 `html` 的内容为空，根据匹配到的内容的长度一点点的增加 `index`，以获取到当前内容在 `template` 中的内容<br/>
最后返回一个有层级管理的AST，AST中的信息有层级，还有元素的属性，但是都是没有值的，并没有和 `data` 结合

### /compiler/index.js
```js
const ast = parse(template.trim(), options)
// 在生成AST之后，生成render之前，有一个优化
if (options.optimize !== false) {
  optimize(ast, options)
}
const code = generate(ast, options)  //code = {render, staticRenderFns}
```

### /compiler/optimizer.js
##### 为node添加static属性
优化判断是否是静态元素， 如果 `node` 中没有 `v-if v-for v-else v-bind` 并且不是自定义的组件，并且 `node` 中的 `key` 都是静态的 `key` 值 包括`type,tag,attrsList,attrsMap,plain,parent,children,attrs,start,end`， 且 `children` 也是静态节点 等条件判断为该node为静态node
##### 为node添加staticRoot属性
如果 `node` 是静态节点即 `static = true`，且有 `children` ，且 `children` 不止一个并且该节点不是文本节点，则判断 `node` 为  `staticRoot = true` 

### /compiler/codegen/index.js
```js
export function generate (
  ast: ASTElement | void,
  options: CompilerOptions
): CodegenResult {
  const state = new CodegenState(options)
  const code = ast ? genElement(ast, state) : '_c("div")'
  return {
    render: `with(this){return ${code}}`,
    staticRenderFns: state.staticRenderFns
  }
}
```
生成 `render` 函数，`staticRenderFns` 函数存放静态节点的生成函数，为数组，在 `render` 函数中只存放 `staticRenderFns` 的下标<br/>
通过对 `AST` 的节点便利递归获取到字符串 `code` ，类似 `with(this){return _c('div',{attrs:{"id":"app"}},[_m(0),_v(" "),_c('div',[_v("\n"+_s(a.b)+"\n")])])}` 通过 `new Function(code)`，生成 `render` 函数
##### 静态节点
静态节点的函数存放在 `staticRenderFns` 中
##### if节点
最终生成三元运算符的格式
##### for节点
最终生成类似 `_l((list),function(item){return _c('span',{key:item.key},[_v(_s(item.key))])})` 的格式



### /platforms/web/runtime/index.js
给 `Vue` 原型添加 `$mount` 和 `__patch__` 方法 <br/>
`__patch__` 方法如果是在浏览器则赋值 `patch` 方法，否则赋值空函数<br/>
`$mount` 函数中去执行 `mountComponent` 方法