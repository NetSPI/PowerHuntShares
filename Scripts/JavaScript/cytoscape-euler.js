(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define([], factory);
	else if(typeof exports === 'object')
		exports["cytoscapeEuler"] = factory();
	else
		root["cytoscapeEuler"] = factory();
})(this, function() {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 11);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


module.exports = Object.assign != null ? Object.assign.bind(Object) : function (tgt) {
  for (var _len = arguments.length, srcs = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
    srcs[_key - 1] = arguments[_key];
  }

  srcs.forEach(function (src) {
    Object.keys(src).forEach(function (k) {
      return tgt[k] = src[k];
    });
  });

  return tgt;
};

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var assign = __webpack_require__(0);

var defaults = Object.freeze({
  source: null,
  target: null,
  length: 80,
  coeff: 0.0002,
  weight: 1
});

function makeSpring(spring) {
  return assign({}, defaults, spring);
}

function applySpring(spring) {
  var body1 = spring.source,
      body2 = spring.target,
      length = spring.length < 0 ? defaults.length : spring.length,
      dx = body2.pos.x - body1.pos.x,
      dy = body2.pos.y - body1.pos.y,
      r = Math.sqrt(dx * dx + dy * dy);

  if (r === 0) {
    dx = (Math.random() - 0.5) / 50;
    dy = (Math.random() - 0.5) / 50;
    r = Math.sqrt(dx * dx + dy * dy);
  }

  var d = r - length;
  var coeff = (!spring.coeff || spring.coeff < 0 ? defaults.springCoeff : spring.coeff) * d / r * spring.weight;

  body1.force.x += coeff * dx;
  body1.force.y += coeff * dy;

  body2.force.x -= coeff * dx;
  body2.force.y -= coeff * dy;
}

module.exports = { makeSpring: makeSpring, applySpring: applySpring };

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

/**
The implementation of the Euler layout algorithm
*/

var Layout = __webpack_require__(13);
var assign = __webpack_require__(0);
var defaults = __webpack_require__(4);

var _require = __webpack_require__(10),
    _tick = _require.tick;

var _require2 = __webpack_require__(7),
    makeQuadtree = _require2.makeQuadtree;

var _require3 = __webpack_require__(3),
    makeBody = _require3.makeBody;

var _require4 = __webpack_require__(1),
    makeSpring = _require4.makeSpring;

var isFn = function isFn(fn) {
  return typeof fn === 'function';
};
var isParent = function isParent(n) {
  return n.isParent();
};
var notIsParent = function notIsParent(n) {
  return !isParent(n);
};
var isLocked = function isLocked(n) {
  return n.locked();
};
var notIsLocked = function notIsLocked(n) {
  return !isLocked(n);
};
var isParentEdge = function isParentEdge(e) {
  return isParent(e.source()) || isParent(e.target());
};
var notIsParentEdge = function notIsParentEdge(e) {
  return !isParentEdge(e);
};
var getBody = function getBody(n) {
  return n.scratch('euler').body;
};
var getNonParentDescendants = function getNonParentDescendants(n) {
  return isParent(n) ? n.descendants().filter(notIsParent) : n;
};

var getScratch = function getScratch(el) {
  var scratch = el.scratch('euler');

  if (!scratch) {
    scratch = {};

    el.scratch('euler', scratch);
  }

  return scratch;
};

var optFn = function optFn(opt, ele) {
  if (isFn(opt)) {
    return opt(ele);
  } else {
    return opt;
  }
};

var Euler = function (_Layout) {
  _inherits(Euler, _Layout);

  function Euler(options) {
    _classCallCheck(this, Euler);

    return _possibleConstructorReturn(this, (Euler.__proto__ || Object.getPrototypeOf(Euler)).call(this, assign({}, defaults, options)));
  }

  _createClass(Euler, [{
    key: 'prerun',
    value: function prerun(state) {
      var s = state;

      s.quadtree = makeQuadtree();

      var bodies = s.bodies = [];

      // regular nodes
      s.nodes.filter(function (n) {
        return notIsParent(n);
      }).forEach(function (n) {
        var scratch = getScratch(n);

        var body = makeBody({
          pos: { x: scratch.x, y: scratch.y },
          mass: optFn(s.mass, n),
          locked: scratch.locked
        });

        body._cyNode = n;

        scratch.body = body;

        body._scratch = scratch;

        bodies.push(body);
      });

      var springs = s.springs = [];

      // regular edge springs
      s.edges.filter(notIsParentEdge).forEach(function (e) {
        var spring = makeSpring({
          source: getBody(e.source()),
          target: getBody(e.target()),
          length: optFn(s.springLength, e),
          coeff: optFn(s.springCoeff, e)
        });

        spring._cyEdge = e;

        var scratch = getScratch(e);

        spring._scratch = scratch;

        scratch.spring = spring;

        springs.push(spring);
      });

      // compound edge springs
      s.edges.filter(isParentEdge).forEach(function (e) {
        var sources = getNonParentDescendants(e.source());
        var targets = getNonParentDescendants(e.target());

        // just add one spring for perf
        sources = [sources[0]];
        targets = [targets[0]];

        sources.forEach(function (src) {
          targets.forEach(function (tgt) {
            springs.push(makeSpring({
              source: getBody(src),
              target: getBody(tgt),
              length: optFn(s.springLength, e),
              coeff: optFn(s.springCoeff, e)
            }));
          });
        });
      });
    }
  }, {
    key: 'tick',
    value: function tick(state) {
      var movement = _tick(state);

      var isDone = movement <= state.movementThreshold;

      return isDone;
    }
  }]);

  return Euler;
}(Layout);

module.exports = Euler;

/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var defaults = Object.freeze({
  pos: { x: 0, y: 0 },
  prevPos: { x: 0, y: 0 },
  force: { x: 0, y: 0 },
  velocity: { x: 0, y: 0 },
  mass: 1
});

var copyVec = function copyVec(v) {
  return { x: v.x, y: v.y };
};
var getValue = function getValue(val, def) {
  return val != null ? val : def;
};
var getVec = function getVec(vec, def) {
  return copyVec(getValue(vec, def));
};

function makeBody(opts) {
  var b = {};

  b.pos = getVec(opts.pos, defaults.pos);
  b.prevPos = getVec(opts.prevPos, b.pos);
  b.force = getVec(opts.force, defaults.force);
  b.velocity = getVec(opts.velocity, defaults.velocity);
  b.mass = opts.mass != null ? opts.mass : defaults.mass;
  b.locked = opts.locked;

  return b;
}

module.exports = { makeBody: makeBody };

/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var defaults = Object.freeze({
  // The ideal legth of a spring
  // - This acts as a hint for the edge length
  // - The edge length can be longer or shorter if the forces are set to extreme values
  springLength: function springLength(edge) {
    return 80;
  },

  // Hooke's law coefficient
  // - The value ranges on [0, 1]
  // - Lower values give looser springs
  // - Higher values give tighter springs
  springCoeff: function springCoeff(edge) {
    return 0.0008;
  },

  // The mass of the node in the physics simulation
  // - The mass affects the gravity node repulsion/attraction
  mass: function mass(node) {
    return 4;
  },

  // Coulomb's law coefficient
  // - Makes the nodes repel each other for negative values
  // - Makes the nodes attract each other for positive values
  gravity: -1.2,

  // A force that pulls nodes towards the origin (0, 0)
  // Higher values keep the components less spread out
  pull: 0.001,

  // Theta coefficient from Barnes-Hut simulation
  // - Value ranges on [0, 1]
  // - Performance is better with smaller values
  // - Very small values may not create enough force to give a good result
  theta: 0.666,

  // Friction / drag coefficient to make the system stabilise over time
  dragCoeff: 0.02,

  // When the total of the squared position deltas is less than this value, the simulation ends
  movementThreshold: 1,

  // The amount of time passed per tick
  // - Larger values result in faster runtimes but might spread things out too far
  // - Smaller values produce more accurate results
  timeStep: 20
});

module.exports = defaults;

/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var defaultCoeff = 0.02;

function applyDrag(body, manualDragCoeff) {
  var dragCoeff = void 0;

  if (manualDragCoeff != null) {
    dragCoeff = manualDragCoeff;
  } else if (body.dragCoeff != null) {
    dragCoeff = body.dragCoeff;
  } else {
    dragCoeff = defaultCoeff;
  }

  body.force.x -= dragCoeff * body.velocity.x;
  body.force.y -= dragCoeff * body.velocity.y;
}

module.exports = { applyDrag: applyDrag };

/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


// use euler method for force integration http://en.wikipedia.org/wiki/Euler_method
// return sum of squared position deltas
function integrate(bodies, timeStep) {
  var dx = 0,
      tx = 0,
      dy = 0,
      ty = 0,
      i,
      max = bodies.length;

  if (max === 0) {
    return 0;
  }

  for (i = 0; i < max; ++i) {
    var body = bodies[i],
        coeff = timeStep / body.mass;

    if (body.grabbed) {
      continue;
    }

    if (body.locked) {
      body.velocity.x = 0;
      body.velocity.y = 0;
    } else {
      body.velocity.x += coeff * body.force.x;
      body.velocity.y += coeff * body.force.y;
    }

    var vx = body.velocity.x,
        vy = body.velocity.y,
        v = Math.sqrt(vx * vx + vy * vy);

    if (v > 1) {
      body.velocity.x = vx / v;
      body.velocity.y = vy / v;
    }

    dx = timeStep * body.velocity.x;
    dy = timeStep * body.velocity.y;

    body.pos.x += dx;
    body.pos.y += dy;

    tx += Math.abs(dx);ty += Math.abs(dy);
  }

  return (tx * tx + ty * ty) / max;
}

module.exports = { integrate: integrate };

/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


// impl of barnes hut
// http://www.eecs.berkeley.edu/~demmel/cs267/lecture26/lecture26.html
// http://en.wikipedia.org/wiki/Barnes%E2%80%93Hut_simulation

var Node = __webpack_require__(9);
var InsertStack = __webpack_require__(8);

var resetVec = function resetVec(v) {
  v.x = 0;v.y = 0;
};

var isSamePosition = function isSamePosition(p1, p2) {
  var threshold = 1e-8;
  var dx = Math.abs(p1.x - p2.x);
  var dy = Math.abs(p1.y - p2.y);

  return dx < threshold && dy < threshold;
};

function makeQuadtree() {
  var updateQueue = [],
      insertStack = new InsertStack(),
      nodesCache = [],
      currentInCache = 0,
      root = newNode();

  function newNode() {
    // To avoid pressure on GC we reuse nodes.
    var node = nodesCache[currentInCache];
    if (node) {
      node.quad0 = null;
      node.quad1 = null;
      node.quad2 = null;
      node.quad3 = null;
      node.body = null;
      node.mass = node.massX = node.massY = 0;
      node.left = node.right = node.top = node.bottom = 0;
    } else {
      node = new Node();
      nodesCache[currentInCache] = node;
    }

    ++currentInCache;
    return node;
  }

  function update(sourceBody, gravity, theta, pull) {
    var queue = updateQueue,
        v = void 0,
        dx = void 0,
        dy = void 0,
        r = void 0,
        fx = 0,
        fy = 0,
        queueLength = 1,
        shiftIdx = 0,
        pushIdx = 1;

    queue[0] = root;

    resetVec(sourceBody.force);

    var px = -sourceBody.pos.x;
    var py = -sourceBody.pos.y;
    var pr = Math.sqrt(px * px + py * py);
    var pv = sourceBody.mass * pull / pr;

    fx += pv * px;
    fy += pv * py;

    while (queueLength) {
      var node = queue[shiftIdx],
          body = node.body;

      queueLength -= 1;
      shiftIdx += 1;
      var differentBody = body !== sourceBody;
      if (body && differentBody) {
        // If the current node is a leaf node (and it is not source body),
        // calculate the force exerted by the current node on body, and add this
        // amount to body's net force.
        dx = body.pos.x - sourceBody.pos.x;
        dy = body.pos.y - sourceBody.pos.y;
        r = Math.sqrt(dx * dx + dy * dy);

        if (r === 0) {
          // Poor man's protection against zero distance.
          dx = (Math.random() - 0.5) / 50;
          dy = (Math.random() - 0.5) / 50;
          r = Math.sqrt(dx * dx + dy * dy);
        }

        // This is standard gravition force calculation but we divide
        // by r^3 to save two operations when normalizing force vector.
        v = gravity * body.mass * sourceBody.mass / (r * r * r);
        fx += v * dx;
        fy += v * dy;
      } else if (differentBody) {
        // Otherwise, calculate the ratio s / r,  where s is the width of the region
        // represented by the internal node, and r is the distance between the body
        // and the node's center-of-mass
        dx = node.massX / node.mass - sourceBody.pos.x;
        dy = node.massY / node.mass - sourceBody.pos.y;
        r = Math.sqrt(dx * dx + dy * dy);

        if (r === 0) {
          // Sorry about code duplucation. I don't want to create many functions
          // right away. Just want to see performance first.
          dx = (Math.random() - 0.5) / 50;
          dy = (Math.random() - 0.5) / 50;
          r = Math.sqrt(dx * dx + dy * dy);
        }
        // If s / r < θ, treat this internal node as a single body, and calculate the
        // force it exerts on sourceBody, and add this amount to sourceBody's net force.
        if ((node.right - node.left) / r < theta) {
          // in the if statement above we consider node's width only
          // because the region was squarified during tree creation.
          // Thus there is no difference between using width or height.
          v = gravity * node.mass * sourceBody.mass / (r * r * r);
          fx += v * dx;
          fy += v * dy;
        } else {
          // Otherwise, run the procedure recursively on each of the current node's children.

          // I intentionally unfolded this loop, to save several CPU cycles.
          if (node.quad0) {
            queue[pushIdx] = node.quad0;
            queueLength += 1;
            pushIdx += 1;
          }
          if (node.quad1) {
            queue[pushIdx] = node.quad1;
            queueLength += 1;
            pushIdx += 1;
          }
          if (node.quad2) {
            queue[pushIdx] = node.quad2;
            queueLength += 1;
            pushIdx += 1;
          }
          if (node.quad3) {
            queue[pushIdx] = node.quad3;
            queueLength += 1;
            pushIdx += 1;
          }
        }
      }
    }

    sourceBody.force.x += fx;
    sourceBody.force.y += fy;
  }

  function insertBodies(bodies) {
    if (bodies.length === 0) {
      return;
    }

    var x1 = Number.MAX_VALUE,
        y1 = Number.MAX_VALUE,
        x2 = Number.MIN_VALUE,
        y2 = Number.MIN_VALUE,
        i = void 0,
        max = bodies.length;

    // To reduce quad tree depth we are looking for exact bounding box of all particles.
    i = max;
    while (i--) {
      var x = bodies[i].pos.x;
      var y = bodies[i].pos.y;
      if (x < x1) {
        x1 = x;
      }
      if (x > x2) {
        x2 = x;
      }
      if (y < y1) {
        y1 = y;
      }
      if (y > y2) {
        y2 = y;
      }
    }

    // Squarify the bounds.
    var dx = x2 - x1,
        dy = y2 - y1;
    if (dx > dy) {
      y2 = y1 + dx;
    } else {
      x2 = x1 + dy;
    }

    currentInCache = 0;
    root = newNode();
    root.left = x1;
    root.right = x2;
    root.top = y1;
    root.bottom = y2;

    i = max - 1;
    if (i >= 0) {
      root.body = bodies[i];
    }
    while (i--) {
      insert(bodies[i], root);
    }
  }

  function insert(newBody) {
    insertStack.reset();
    insertStack.push(root, newBody);

    while (!insertStack.isEmpty()) {
      var stackItem = insertStack.pop(),
          node = stackItem.node,
          body = stackItem.body;

      if (!node.body) {
        // This is internal node. Update the total mass of the node and center-of-mass.
        var x = body.pos.x;
        var y = body.pos.y;
        node.mass = node.mass + body.mass;
        node.massX = node.massX + body.mass * x;
        node.massY = node.massY + body.mass * y;

        // Recursively insert the body in the appropriate quadrant.
        // But first find the appropriate quadrant.
        var quadIdx = 0,
            // Assume we are in the 0's quad.
        left = node.left,
            right = (node.right + left) / 2,
            top = node.top,
            bottom = (node.bottom + top) / 2;

        if (x > right) {
          // somewhere in the eastern part.
          quadIdx = quadIdx + 1;
          left = right;
          right = node.right;
        }
        if (y > bottom) {
          // and in south.
          quadIdx = quadIdx + 2;
          top = bottom;
          bottom = node.bottom;
        }

        var child = getChild(node, quadIdx);
        if (!child) {
          // The node is internal but this quadrant is not taken. Add
          // subnode to it.
          child = newNode();
          child.left = left;
          child.top = top;
          child.right = right;
          child.bottom = bottom;
          child.body = body;

          setChild(node, quadIdx, child);
        } else {
          // continue searching in this quadrant.
          insertStack.push(child, body);
        }
      } else {
        // We are trying to add to the leaf node.
        // We have to convert current leaf into internal node
        // and continue adding two nodes.
        var oldBody = node.body;
        node.body = null; // internal nodes do not cary bodies

        if (isSamePosition(oldBody.pos, body.pos)) {
          // Prevent infinite subdivision by bumping one node
          // anywhere in this quadrant
          var retriesCount = 3;
          do {
            var offset = Math.random();
            var dx = (node.right - node.left) * offset;
            var dy = (node.bottom - node.top) * offset;

            oldBody.pos.x = node.left + dx;
            oldBody.pos.y = node.top + dy;
            retriesCount -= 1;
            // Make sure we don't bump it out of the box. If we do, next iteration should fix it
          } while (retriesCount > 0 && isSamePosition(oldBody.pos, body.pos));

          if (retriesCount === 0 && isSamePosition(oldBody.pos, body.pos)) {
            // This is very bad, we ran out of precision.
            // if we do not return from the method we'll get into
            // infinite loop here. So we sacrifice correctness of layout, and keep the app running
            // Next layout iteration should get larger bounding box in the first step and fix this
            return;
          }
        }
        // Next iteration should subdivide node further.
        insertStack.push(node, oldBody);
        insertStack.push(node, body);
      }
    }
  }

  return {
    insertBodies: insertBodies,
    updateBodyForce: update
  };
}

function getChild(node, idx) {
  if (idx === 0) return node.quad0;
  if (idx === 1) return node.quad1;
  if (idx === 2) return node.quad2;
  if (idx === 3) return node.quad3;
  return null;
}

function setChild(node, idx, child) {
  if (idx === 0) node.quad0 = child;else if (idx === 1) node.quad1 = child;else if (idx === 2) node.quad2 = child;else if (idx === 3) node.quad3 = child;
}

module.exports = { makeQuadtree: makeQuadtree };

/***/ }),
/* 8 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


module.exports = InsertStack;

/**
 * Our implmentation of QuadTree is non-recursive to avoid GC hit
 * This data structure represent stack of elements
 * which we are trying to insert into quad tree.
 */
function InsertStack() {
    this.stack = [];
    this.popIdx = 0;
}

InsertStack.prototype = {
    isEmpty: function isEmpty() {
        return this.popIdx === 0;
    },
    push: function push(node, body) {
        var item = this.stack[this.popIdx];
        if (!item) {
            // we are trying to avoid memory pressue: create new element
            // only when absolutely necessary
            this.stack[this.popIdx] = new InsertStackElement(node, body);
        } else {
            item.node = node;
            item.body = body;
        }
        ++this.popIdx;
    },
    pop: function pop() {
        if (this.popIdx > 0) {
            return this.stack[--this.popIdx];
        }
    },
    reset: function reset() {
        this.popIdx = 0;
    }
};

function InsertStackElement(node, body) {
    this.node = node; // QuadTree node
    this.body = body; // physical body which needs to be inserted to node
}

/***/ }),
/* 9 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


/**
 * Internal data structure to represent 2D QuadTree node
 */
module.exports = function Node() {
  // body stored inside this node. In quad tree only leaf nodes (by construction)
  // contain boides:
  this.body = null;

  // Child nodes are stored in quads. Each quad is presented by number:
  // 0 | 1
  // -----
  // 2 | 3
  this.quad0 = null;
  this.quad1 = null;
  this.quad2 = null;
  this.quad3 = null;

  // Total mass of current node
  this.mass = 0;

  // Center of mass coordinates
  this.massX = 0;
  this.massY = 0;

  // bounding box coordinates
  this.left = 0;
  this.top = 0;
  this.bottom = 0;
  this.right = 0;
};

/***/ }),
/* 10 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _require = __webpack_require__(6),
    integrate = _require.integrate;

var _require2 = __webpack_require__(5),
    applyDrag = _require2.applyDrag;

var _require3 = __webpack_require__(1),
    applySpring = _require3.applySpring;

function tick(_ref) {
  var bodies = _ref.bodies,
      springs = _ref.springs,
      quadtree = _ref.quadtree,
      timeStep = _ref.timeStep,
      gravity = _ref.gravity,
      theta = _ref.theta,
      dragCoeff = _ref.dragCoeff,
      pull = _ref.pull;

  // update body from scratch in case of any changes
  bodies.forEach(function (body) {
    var p = body._scratch;

    if (!p) {
      return;
    }

    body.locked = p.locked;
    body.grabbed = p.grabbed;
    body.pos.x = p.x;
    body.pos.y = p.y;
  });

  quadtree.insertBodies(bodies);

  for (var i = 0; i < bodies.length; i++) {
    var body = bodies[i];

    quadtree.updateBodyForce(body, gravity, theta, pull);
    applyDrag(body, dragCoeff);
  }

  for (var _i = 0; _i < springs.length; _i++) {
    var spring = springs[_i];

    applySpring(spring);
  }

  var movement = integrate(bodies, timeStep);

  // update scratch positions from body positions
  bodies.forEach(function (body) {
    var p = body._scratch;

    if (!p) {
      return;
    }

    p.x = body.pos.x;
    p.y = body.pos.y;
  });

  return movement;
}

module.exports = { tick: tick };

/***/ }),
/* 11 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var Euler = __webpack_require__(2);

// registers the extension on a cytoscape lib ref
var register = function register(cytoscape) {
  if (!cytoscape) {
    return;
  } // can't register if cytoscape unspecified

  cytoscape('layout', 'euler', Euler); // register with cytoscape.js
};

if (typeof cytoscape !== 'undefined') {
  // expose to global cytoscape (i.e. window.cytoscape)
  register(cytoscape);
}

module.exports = register;

/***/ }),
/* 12 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


// general default options for force-directed layout

module.exports = Object.freeze({
  animate: true, // whether to show the layout as it's running; special 'end' value makes the layout animate like a discrete layout
  refresh: 10, // number of ticks per frame; higher is faster but more jerky
  maxIterations: 1000, // max iterations before the layout will bail out
  maxSimulationTime: 4000, // max length in ms to run the layout
  ungrabifyWhileSimulating: false, // so you can't drag nodes during layout
  fit: true, // on every layout reposition of nodes, fit the viewport
  padding: 30, // padding around the simulation
  boundingBox: undefined, // constrain layout bounds; { x1, y1, x2, y2 } or { x1, y1, w, h }

  // layout event callbacks
  ready: function ready() {}, // on layoutready
  stop: function stop() {}, // on layoutstop

  // positioning options
  randomize: false, // use random node positions at beginning of layout

  // infinite layout options
  infinite: false // overrides all other options for a forces-all-the-time mode
});

/***/ }),
/* 13 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/**
A generic continuous layout class
*/

var assign = __webpack_require__(0);
var defaults = __webpack_require__(12);
var makeBoundingBox = __webpack_require__(14);

var _require = __webpack_require__(15),
    setInitialPositionState = _require.setInitialPositionState,
    refreshPositions = _require.refreshPositions,
    getNodePositionData = _require.getNodePositionData;

var _require2 = __webpack_require__(16),
    multitick = _require2.multitick;

var Layout = function () {
  function Layout(options) {
    _classCallCheck(this, Layout);

    var o = this.options = assign({}, defaults, options);

    var nodes = o.eles.nodes();
    // prevent infinite loop and memory overflow when nodes occupy the same position
    if (!o.randomize) {
      nodes = nodes.sort(function (a, b) {
        return a.position().x - b.position().x;
      });
      var prev = { x: 0, y: 0 };
      var pos = {};
      nodes.forEach(function (n) {
        Object.assign(pos, n.position());
        if (Math.abs(prev.x - pos.x) < o.theta && Math.abs(prev.y - pos.y) < o.theta) {
          n.position({ x: Math.random() * 100, y: Math.random() * 100 });
        }
        Object.assign(prev, pos);
      });
    }

    var s = this.state = assign({}, o, {
      layout: this,
      nodes: nodes,
      edges: o.eles.edges(),
      tickIndex: 0,
      firstUpdate: true
    });

    s.animateEnd = o.animate && o.animate === 'end';
    s.animateContinuously = o.animate && !s.animateEnd;
  }

  _createClass(Layout, [{
    key: 'run',
    value: function run() {
      var l = this;
      var s = this.state;

      s.tickIndex = 0;
      s.firstUpdate = true;
      s.startTime = Date.now();
      s.running = true;

      s.currentBoundingBox = makeBoundingBox(s.boundingBox, s.cy);

      if (s.ready) {
        l.one('ready', s.ready);
      }
      if (s.stop) {
        l.one('stop', s.stop);
      }

      s.nodes.forEach(function (n) {
        return setInitialPositionState(n, s);
      });

      l.prerun(s);

      if (s.animateContinuously) {
        var ungrabify = function ungrabify(node) {
          if (!s.ungrabifyWhileSimulating) {
            return;
          }

          var grabbable = getNodePositionData(node, s).grabbable = node.grabbable();

          if (grabbable) {
            node.ungrabify();
          }
        };

        var regrabify = function regrabify(node) {
          if (!s.ungrabifyWhileSimulating) {
            return;
          }

          var grabbable = getNodePositionData(node, s).grabbable;

          if (grabbable) {
            node.grabify();
          }
        };

        var updateGrabState = function updateGrabState(node) {
          return getNodePositionData(node, s).grabbed = node.grabbed();
        };

        var onGrab = function onGrab(_ref) {
          var target = _ref.target;

          updateGrabState(target);
        };

        var onFree = onGrab;

        var onDrag = function onDrag(_ref2) {
          var target = _ref2.target;

          var p = getNodePositionData(target, s);
          var tp = target.position();

          p.x = tp.x;
          p.y = tp.y;
        };

        var listenToGrab = function listenToGrab(node) {
          node.on('grab', onGrab);
          node.on('free', onFree);
          node.on('drag', onDrag);
        };

        var unlistenToGrab = function unlistenToGrab(node) {
          node.removeListener('grab', onGrab);
          node.removeListener('free', onFree);
          node.removeListener('drag', onDrag);
        };

        var fit = function fit() {
          if (s.fit && s.animateContinuously) {
            s.cy.fit(s.padding);
          }
        };

        var onNotDone = function onNotDone() {
          refreshPositions(s.nodes, s);
          fit();

          requestAnimationFrame(_frame);
        };

        var _frame = function _frame() {
          multitick(s, onNotDone, _onDone);
        };

        var _onDone = function _onDone() {
          refreshPositions(s.nodes, s);
          fit();

          s.nodes.forEach(function (n) {
            regrabify(n);
            unlistenToGrab(n);
          });

          s.running = false;

          l.emit('layoutstop');
        };

        l.emit('layoutstart');

        s.nodes.forEach(function (n) {
          ungrabify(n);
          listenToGrab(n);
        });

        _frame(); // kick off
      } else {
        var done = false;
        var _onNotDone = function _onNotDone() {};
        var _onDone2 = function _onDone2() {
          return done = true;
        };

        while (!done) {
          multitick(s, _onNotDone, _onDone2);
        }

        s.eles.layoutPositions(this, s, function (node) {
          var pd = getNodePositionData(node, s);

          return { x: pd.x, y: pd.y };
        });
      }

      l.postrun(s);

      return this; // chaining
    }
  }, {
    key: 'prerun',
    value: function prerun() {}
  }, {
    key: 'postrun',
    value: function postrun() {}
  }, {
    key: 'tick',
    value: function tick() {}
  }, {
    key: 'stop',
    value: function stop() {
      this.state.running = false;

      return this; // chaining
    }
  }, {
    key: 'destroy',
    value: function destroy() {
      return this; // chaining
    }
  }]);

  return Layout;
}();

module.exports = Layout;

/***/ }),
/* 14 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


module.exports = function (bb, cy) {
  if (bb == null) {
    bb = { x1: 0, y1: 0, w: cy.width(), h: cy.height() };
  } else {
    // copy
    bb = { x1: bb.x1, x2: bb.x2, y1: bb.y1, y2: bb.y2, w: bb.w, h: bb.h };
  }

  if (bb.x2 == null) {
    bb.x2 = bb.x1 + bb.w;
  }
  if (bb.w == null) {
    bb.w = bb.x2 - bb.x1;
  }
  if (bb.y2 == null) {
    bb.y2 = bb.y1 + bb.h;
  }
  if (bb.h == null) {
    bb.h = bb.y2 - bb.y1;
  }

  return bb;
};

/***/ }),
/* 15 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var assign = __webpack_require__(0);

var setInitialPositionState = function setInitialPositionState(node, state) {
  var p = node.position();
  var bb = state.currentBoundingBox;
  var scratch = node.scratch(state.name);

  if (scratch == null) {
    scratch = {};

    node.scratch(state.name, scratch);
  }

  assign(scratch, state.randomize ? {
    x: bb.x1 + Math.random() * bb.w,
    y: bb.y1 + Math.random() * bb.h
  } : {
    x: p.x,
    y: p.y
  });

  scratch.locked = node.locked();
};

var getNodePositionData = function getNodePositionData(node, state) {
  return node.scratch(state.name);
};

var refreshPositions = function refreshPositions(nodes, state) {
  nodes.positions(function (node) {
    var scratch = node.scratch(state.name);

    return {
      x: scratch.x,
      y: scratch.y
    };
  });
};

module.exports = { setInitialPositionState: setInitialPositionState, getNodePositionData: getNodePositionData, refreshPositions: refreshPositions };

/***/ }),
/* 16 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var nop = function nop() {};

var tick = function tick(state) {
  var s = state;
  var l = state.layout;

  var tickIndicatesDone = l.tick(s);

  if (s.firstUpdate) {
    if (s.animateContinuously) {
      // indicate the initial positions have been set
      s.layout.emit('layoutready');
    }
    s.firstUpdate = false;
  }

  s.tickIndex++;

  var duration = Date.now() - s.startTime;

  return !s.infinite && (tickIndicatesDone || s.tickIndex >= s.maxIterations || duration >= s.maxSimulationTime);
};

var multitick = function multitick(state) {
  var onNotDone = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : nop;
  var onDone = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : nop;

  var done = false;
  var s = state;

  for (var i = 0; i < s.refresh; i++) {
    done = !s.running || tick(s);

    if (done) {
      break;
    }
  }

  if (!done) {
    onNotDone();
  } else {
    onDone();
  }
};

module.exports = { tick: tick, multitick: multitick };

/***/ })
/******/ ]);
});
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay91bml2ZXJzYWxNb2R1bGVEZWZpbml0aW9uIiwid2VicGFjazovLy93ZWJwYWNrL2Jvb3RzdHJhcCA1MGJjNjVjOTlhYjVjZjA4ZWUzZSIsIndlYnBhY2s6Ly8vLi9zcmMvYXNzaWduLmpzIiwid2VicGFjazovLy8uL3NyYy9ldWxlci9zcHJpbmcuanMiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V1bGVyL2luZGV4LmpzIiwid2VicGFjazovLy8uL3NyYy9ldWxlci9ib2R5LmpzIiwid2VicGFjazovLy8uL3NyYy9ldWxlci9kZWZhdWx0cy5qcyIsIndlYnBhY2s6Ly8vLi9zcmMvZXVsZXIvZHJhZy5qcyIsIndlYnBhY2s6Ly8vLi9zcmMvZXVsZXIvaW50ZWdyYXRlLmpzIiwid2VicGFjazovLy8uL3NyYy9ldWxlci9xdWFkdHJlZS9pbmRleC5qcyIsIndlYnBhY2s6Ly8vLi9zcmMvZXVsZXIvcXVhZHRyZWUvaW5zZXJ0U3RhY2suanMiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V1bGVyL3F1YWR0cmVlL25vZGUuanMiLCJ3ZWJwYWNrOi8vLy4vc3JjL2V1bGVyL3RpY2suanMiLCJ3ZWJwYWNrOi8vLy4vc3JjL2luZGV4LmpzIiwid2VicGFjazovLy8uL3NyYy9sYXlvdXQvZGVmYXVsdHMuanMiLCJ3ZWJwYWNrOi8vLy4vc3JjL2xheW91dC9pbmRleC5qcyIsIndlYnBhY2s6Ly8vLi9zcmMvbGF5b3V0L21ha2UtYmIuanMiLCJ3ZWJwYWNrOi8vLy4vc3JjL2xheW91dC9wb3NpdGlvbi5qcyIsIndlYnBhY2s6Ly8vLi9zcmMvbGF5b3V0L3RpY2suanMiXSwibmFtZXMiOlsibW9kdWxlIiwiZXhwb3J0cyIsIk9iamVjdCIsImFzc2lnbiIsImJpbmQiLCJ0Z3QiLCJzcmNzIiwiZm9yRWFjaCIsImtleXMiLCJzcmMiLCJrIiwicmVxdWlyZSIsImRlZmF1bHRzIiwiZnJlZXplIiwic291cmNlIiwidGFyZ2V0IiwibGVuZ3RoIiwiY29lZmYiLCJ3ZWlnaHQiLCJtYWtlU3ByaW5nIiwic3ByaW5nIiwiYXBwbHlTcHJpbmciLCJib2R5MSIsImJvZHkyIiwiZHgiLCJwb3MiLCJ4IiwiZHkiLCJ5IiwiciIsIk1hdGgiLCJzcXJ0IiwicmFuZG9tIiwiZCIsInNwcmluZ0NvZWZmIiwiZm9yY2UiLCJMYXlvdXQiLCJ0aWNrIiwibWFrZVF1YWR0cmVlIiwibWFrZUJvZHkiLCJpc0ZuIiwiZm4iLCJpc1BhcmVudCIsIm4iLCJub3RJc1BhcmVudCIsImlzTG9ja2VkIiwibG9ja2VkIiwibm90SXNMb2NrZWQiLCJpc1BhcmVudEVkZ2UiLCJlIiwibm90SXNQYXJlbnRFZGdlIiwiZ2V0Qm9keSIsInNjcmF0Y2giLCJib2R5IiwiZ2V0Tm9uUGFyZW50RGVzY2VuZGFudHMiLCJkZXNjZW5kYW50cyIsImZpbHRlciIsImdldFNjcmF0Y2giLCJlbCIsIm9wdEZuIiwib3B0IiwiZWxlIiwiRXVsZXIiLCJvcHRpb25zIiwic3RhdGUiLCJzIiwicXVhZHRyZWUiLCJib2RpZXMiLCJub2RlcyIsIm1hc3MiLCJfY3lOb2RlIiwiX3NjcmF0Y2giLCJwdXNoIiwic3ByaW5ncyIsImVkZ2VzIiwic3ByaW5nTGVuZ3RoIiwiX2N5RWRnZSIsInNvdXJjZXMiLCJ0YXJnZXRzIiwibW92ZW1lbnQiLCJpc0RvbmUiLCJtb3ZlbWVudFRocmVzaG9sZCIsInByZXZQb3MiLCJ2ZWxvY2l0eSIsImNvcHlWZWMiLCJ2IiwiZ2V0VmFsdWUiLCJ2YWwiLCJkZWYiLCJnZXRWZWMiLCJ2ZWMiLCJvcHRzIiwiYiIsImdyYXZpdHkiLCJwdWxsIiwidGhldGEiLCJkcmFnQ29lZmYiLCJ0aW1lU3RlcCIsImRlZmF1bHRDb2VmZiIsImFwcGx5RHJhZyIsIm1hbnVhbERyYWdDb2VmZiIsImludGVncmF0ZSIsInR4IiwidHkiLCJpIiwibWF4IiwiZ3JhYmJlZCIsInZ4IiwidnkiLCJhYnMiLCJOb2RlIiwiSW5zZXJ0U3RhY2siLCJyZXNldFZlYyIsImlzU2FtZVBvc2l0aW9uIiwicDEiLCJwMiIsInRocmVzaG9sZCIsInVwZGF0ZVF1ZXVlIiwiaW5zZXJ0U3RhY2siLCJub2Rlc0NhY2hlIiwiY3VycmVudEluQ2FjaGUiLCJyb290IiwibmV3Tm9kZSIsIm5vZGUiLCJxdWFkMCIsInF1YWQxIiwicXVhZDIiLCJxdWFkMyIsIm1hc3NYIiwibWFzc1kiLCJsZWZ0IiwicmlnaHQiLCJ0b3AiLCJib3R0b20iLCJ1cGRhdGUiLCJzb3VyY2VCb2R5IiwicXVldWUiLCJmeCIsImZ5IiwicXVldWVMZW5ndGgiLCJzaGlmdElkeCIsInB1c2hJZHgiLCJweCIsInB5IiwicHIiLCJwdiIsImRpZmZlcmVudEJvZHkiLCJpbnNlcnRCb2RpZXMiLCJ4MSIsIk51bWJlciIsIk1BWF9WQUxVRSIsInkxIiwieDIiLCJNSU5fVkFMVUUiLCJ5MiIsImluc2VydCIsIm5ld0JvZHkiLCJyZXNldCIsImlzRW1wdHkiLCJzdGFja0l0ZW0iLCJwb3AiLCJxdWFkSWR4IiwiY2hpbGQiLCJnZXRDaGlsZCIsInNldENoaWxkIiwib2xkQm9keSIsInJldHJpZXNDb3VudCIsIm9mZnNldCIsInVwZGF0ZUJvZHlGb3JjZSIsImlkeCIsInN0YWNrIiwicG9wSWR4IiwicHJvdG90eXBlIiwiaXRlbSIsIkluc2VydFN0YWNrRWxlbWVudCIsInAiLCJyZWdpc3RlciIsImN5dG9zY2FwZSIsImFuaW1hdGUiLCJyZWZyZXNoIiwibWF4SXRlcmF0aW9ucyIsIm1heFNpbXVsYXRpb25UaW1lIiwidW5ncmFiaWZ5V2hpbGVTaW11bGF0aW5nIiwiZml0IiwicGFkZGluZyIsImJvdW5kaW5nQm94IiwidW5kZWZpbmVkIiwicmVhZHkiLCJzdG9wIiwicmFuZG9taXplIiwiaW5maW5pdGUiLCJtYWtlQm91bmRpbmdCb3giLCJzZXRJbml0aWFsUG9zaXRpb25TdGF0ZSIsInJlZnJlc2hQb3NpdGlvbnMiLCJnZXROb2RlUG9zaXRpb25EYXRhIiwibXVsdGl0aWNrIiwibyIsImVsZXMiLCJzb3J0IiwiYSIsInBvc2l0aW9uIiwicHJldiIsImxheW91dCIsInRpY2tJbmRleCIsImZpcnN0VXBkYXRlIiwiYW5pbWF0ZUVuZCIsImFuaW1hdGVDb250aW51b3VzbHkiLCJsIiwic3RhcnRUaW1lIiwiRGF0ZSIsIm5vdyIsInJ1bm5pbmciLCJjdXJyZW50Qm91bmRpbmdCb3giLCJjeSIsIm9uZSIsInByZXJ1biIsInVuZ3JhYmlmeSIsImdyYWJiYWJsZSIsInJlZ3JhYmlmeSIsImdyYWJpZnkiLCJ1cGRhdGVHcmFiU3RhdGUiLCJvbkdyYWIiLCJvbkZyZWUiLCJvbkRyYWciLCJ0cCIsImxpc3RlblRvR3JhYiIsIm9uIiwidW5saXN0ZW5Ub0dyYWIiLCJyZW1vdmVMaXN0ZW5lciIsIm9uTm90RG9uZSIsInJlcXVlc3RBbmltYXRpb25GcmFtZSIsImZyYW1lIiwib25Eb25lIiwiZW1pdCIsImRvbmUiLCJsYXlvdXRQb3NpdGlvbnMiLCJwZCIsInBvc3RydW4iLCJiYiIsInciLCJ3aWR0aCIsImgiLCJoZWlnaHQiLCJuYW1lIiwicG9zaXRpb25zIiwibm9wIiwidGlja0luZGljYXRlc0RvbmUiLCJkdXJhdGlvbiJdLCJtYXBwaW5ncyI6IkFBQUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0EsQ0FBQztBQUNELE87UUNWQTtRQUNBOztRQUVBO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7O1FBRUE7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0E7UUFDQTs7O1FBR0E7UUFDQTs7UUFFQTtRQUNBOztRQUVBO1FBQ0EsMkNBQTJDLGNBQWM7O1FBRXpEO1FBQ0E7UUFDQTtRQUNBO1FBQ0E7UUFDQTtRQUNBO1FBQ0EsS0FBSztRQUNMO1FBQ0E7O1FBRUE7UUFDQTtRQUNBO1FBQ0EsMkJBQTJCLDBCQUEwQixFQUFFO1FBQ3ZELGlDQUFpQyxlQUFlO1FBQ2hEO1FBQ0E7UUFDQTs7UUFFQTtRQUNBLHNEQUFzRCwrREFBK0Q7O1FBRXJIO1FBQ0E7O1FBRUE7UUFDQTs7Ozs7Ozs7OztBQ2hFQUEsT0FBT0Ms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RUFBRWtKLE9BQUgsSUFBYzlLLEtBQU00QixDQUFOLENBQXJCOztBQUVBLFFBQUl5SyxJQUFKLEVBQVU7QUFBRTtBQUFRO0FBQ3JCOztBQUVELE1BQUksQ0FBQ0EsSUFBTCxFQUFXO0FBQ1RMO0FBQ0QsR0FGRCxNQUVPO0FBQ0xHO0FBQ0Q7QUFDRixDQWZEOztBQWlCQXhPLE9BQU9DLE9BQVAsR0FBaUIsRUFBRW9DLFVBQUYsRUFBUThKLG9CQUFSLEVBQWpCLEMiLCJmaWxlIjoiY3l0b3NjYXBlLWV1bGVyLmpzIiwic291cmNlc0NvbnRlbnQiOlsiKGZ1bmN0aW9uIHdlYnBhY2tVbml2ZXJzYWxNb2R1bGVEZWZpbml0aW9uKHJvb3QsIGZhY3RvcnkpIHtcblx0aWYodHlwZW9mIGV4cG9ydHMgPT09ICdvYmplY3QnICYmIHR5cGVvZiBtb2R1bGUgPT09ICdvYmplY3QnKVxuXHRcdG1vZHVsZS5leHBvcnRzID0gZmFjdG9yeSgpO1xuXHRlbHNlIGlmKHR5cGVvZiBkZWZpbmUgPT09ICdmdW5jdGlvbicgJiYgZGVmaW5lLmFtZClcblx0XHRkZWZpbmUoW10sIGZhY3RvcnkpO1xuXHRlbHNlIGlmKHR5cGVvZiBleHBvcnRzID09PSAnb2JqZWN0Jylcblx0XHRleHBvcnRzW1wiY3l0b3NjYXBlRXVsZXJcIl0gPSBmYWN0b3J5KCk7XG5cdGVsc2Vcblx0XHRyb290W1wiY3l0b3NjYXBlRXVsZXJcIl0gPSBmYWN0b3J5KCk7XG59KSh0aGlzLCBmdW5jdGlvbigpIHtcbnJldHVybiBcblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gd2VicGFjay91bml2ZXJzYWxNb2R1bGVEZWZpbml0aW9uIiwiIFx0Ly8gVGhlIG1vZHVsZSBjYWNoZVxuIFx0dmFyIGluc3RhbGxlZE1vZHVsZXMgPSB7fTtcblxuIFx0Ly8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbiBcdGZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblxuIFx0XHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcbiBcdFx0aWYoaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0pIHtcbiBcdFx0XHRyZXR1cm4gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0uZXhwb3J0cztcbiBcdFx0fVxuIFx0XHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuIFx0XHR2YXIgbW9kdWxlID0gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0gPSB7XG4gXHRcdFx0aTogbW9kdWxlSWQsXG4gXHRcdFx0bDogZmFsc2UsXG4gXHRcdFx0ZXhwb3J0czoge31cbiBcdFx0fTtcblxuIFx0XHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cbiBcdFx0bW9kdWxlc1ttb2R1bGVJZF0uY2FsbChtb2R1bGUuZXhwb3J0cywgbW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cbiBcdFx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuIFx0XHRtb2R1bGUubCA9IHRydWU7XG5cbiBcdFx0Ly8gUmV0dXJuIHRoZSBleHBvcnRzIG9mIHRoZSBtb2R1bGVcbiBcdFx0cmV0dXJuIG1vZHVsZS5leHBvcnRzO1xuIFx0fVxuXG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlcyBvYmplY3QgKF9fd2VicGFja19tb2R1bGVzX18pXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm0gPSBtb2R1bGVzO1xuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZSBjYWNoZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5jID0gaW5zdGFsbGVkTW9kdWxlcztcblxuIFx0Ly8gaWRlbnRpdHkgZnVuY3Rpb24gZm9yIGNhbGxpbmcgaGFybW9ueSBpbXBvcnRzIHdpdGggdGhlIGNvcnJlY3QgY29udGV4dFxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5pID0gZnVuY3Rpb24odmFsdWUpIHsgcmV0dXJuIHZhbHVlOyB9O1xuXG4gXHQvLyBkZWZpbmUgZ2V0dGVyIGZ1bmN0aW9uIGZvciBoYXJtb255IGV4cG9ydHNcbiBcdF9fd2VicGFja19yZXF1aXJlX18uZCA9IGZ1bmN0aW9uKGV4cG9ydHMsIG5hbWUsIGdldHRlcikge1xuIFx0XHRpZighX193ZWJwYWNrX3JlcXVpcmVfXy5vKGV4cG9ydHMsIG5hbWUpKSB7XG4gXHRcdFx0T2JqZWN0LmRlZmluZVByb3BlcnR5KGV4cG9ydHMsIG5hbWUsIHtcbiBcdFx0XHRcdGNvbmZpZ3VyYWJsZTogZmFsc2UsXG4gXHRcdFx0XHRlbnVtZXJhYmxlOiB0cnVlLFxuIFx0XHRcdFx0Z2V0OiBnZXR0ZXJcbiBcdFx0XHR9KTtcbiBcdFx0fVxuIFx0fTtcblxuIFx0Ly8gZ2V0RGVmYXVsdEV4cG9ydCBmdW5jdGlvbiBmb3IgY29tcGF0aWJpbGl0eSB3aXRoIG5vbi1oYXJtb255IG1vZHVsZXNcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubiA9IGZ1bmN0aW9uKG1vZHVsZSkge1xuIFx0XHR2YXIgZ2V0dGVyID0gbW9kdWxlICYmIG1vZHVsZS5fX2VzTW9kdWxlID9cbiBcdFx0XHRmdW5jdGlvbiBnZXREZWZhdWx0KCkgeyByZXR1cm4gbW9kdWxlWydkZWZhdWx0J107IH0gOlxuIFx0XHRcdGZ1bmN0aW9uIGdldE1vZHVsZUV4cG9ydHMoKSB7IHJldHVybiBtb2R1bGU7IH07XG4gXHRcdF9fd2VicGFja19yZXF1aXJlX18uZChnZXR0ZXIsICdhJywgZ2V0dGVyKTtcbiBcdFx0cmV0dXJuIGdldHRlcjtcbiBcdH07XG5cbiBcdC8vIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbFxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5vID0gZnVuY3Rpb24ob2JqZWN0LCBwcm9wZXJ0eSkgeyByZXR1cm4gT2JqZWN0LnByb3RvdHlwZS5oYXNPd25Qcm9wZXJ0eS5jYWxsKG9iamVjdCwgcHJvcGVydHkpOyB9O1xuXG4gXHQvLyBfX3dlYnBhY2tfcHVibGljX3BhdGhfX1xuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5wID0gXCJcIjtcblxuIFx0Ly8gTG9hZCBlbnRyeSBtb2R1bGUgYW5kIHJldHVybiBleHBvcnRzXG4gXHRyZXR1cm4gX193ZWJwYWNrX3JlcXVpcmVfXyhfX3dlYnBhY2tfcmVxdWlyZV9fLnMgPSAxMSk7XG5cblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gd2VicGFjay9ib290c3RyYXAgNTBiYzY1Yzk5YWI1Y2YwOGVlM2UiLCJtb2R1bGUuZXhwb3J0cyA9IE9iamVjdC5hc3NpZ24gIT0gbnVsbCA/IE9iamVjdC5hc3NpZ24uYmluZCggT2JqZWN0ICkgOiBmdW5jdGlvbiggdGd0LCAuLi5zcmNzICl7XG4gIHNyY3MuZm9yRWFjaCggc3JjID0+IHtcbiAgICBPYmplY3Qua2V5cyggc3JjICkuZm9yRWFjaCggayA9PiB0Z3Rba10gPSBzcmNba10gKTtcbiAgfSApO1xuXG4gIHJldHVybiB0Z3Q7XG59O1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2Fzc2lnbi5qcyIsImNvbnN0IGFzc2lnbiA9IHJlcXVpcmUoJy4uL2Fzc2lnbicpO1xuXG5jb25zdCBkZWZhdWx0cyA9IE9iamVjdC5mcmVlemUoe1xuICBzb3VyY2U6IG51bGwsXG4gIHRhcmdldDogbnVsbCxcbiAgbGVuZ3RoOiA4MCxcbiAgY29lZmY6IDAuMDAwMixcbiAgd2VpZ2h0OiAxXG59KTtcblxuZnVuY3Rpb24gbWFrZVNwcmluZyggc3ByaW5nICl7XG4gIHJldHVybiBhc3NpZ24oIHt9LCBkZWZhdWx0cywgc3ByaW5nICk7XG59XG5cbmZ1bmN0aW9uIGFwcGx5U3ByaW5nKCBzcHJpbmcgKXtcbiAgbGV0IGJvZHkxID0gc3ByaW5nLnNvdXJjZSxcbiAgICAgIGJvZHkyID0gc3ByaW5nLnRhcmdldCxcbiAgICAgIGxlbmd0aCA9IHNwcmluZy5sZW5ndGggPCAwID8gZGVmYXVsdHMubGVuZ3RoIDogc3ByaW5nLmxlbmd0aCxcbiAgICAgIGR4ID0gYm9keTIucG9zLnggLSBib2R5MS5wb3MueCxcbiAgICAgIGR5ID0gYm9keTIucG9zLnkgLSBib2R5MS5wb3MueSxcbiAgICAgIHIgPSBNYXRoLnNxcnQoZHggKiBkeCArIGR5ICogZHkpO1xuXG4gIGlmIChyID09PSAwKSB7XG4gICAgICBkeCA9IChNYXRoLnJhbmRvbSgpIC0gMC41KSAvIDUwO1xuICAgICAgZHkgPSAoTWF0aC5yYW5kb20oKSAtIDAuNSkgLyA1MDtcbiAgICAgIHIgPSBNYXRoLnNxcnQoZHggKiBkeCArIGR5ICogZHkpO1xuICB9XG5cbiAgbGV0IGQgPSByIC0gbGVuZ3RoO1xuICBsZXQgY29lZmYgPSAoKCFzcHJpbmcuY29lZmYgfHwgc3ByaW5nLmNvZWZmIDwgMCkgPyBkZWZhdWx0cy5zcHJpbmdDb2VmZiA6IHNwcmluZy5jb2VmZikgKiBkIC8gciAqIHNwcmluZy53ZWlnaHQ7XG5cbiAgYm9keTEuZm9yY2UueCArPSBjb2VmZiAqIGR4O1xuICBib2R5MS5mb3JjZS55ICs9IGNvZWZmICogZHk7XG5cbiAgYm9keTIuZm9yY2UueCAtPSBjb2VmZiAqIGR4O1xuICBib2R5Mi5mb3JjZS55IC09IGNvZWZmICogZHk7XG59XG5cbm1vZHVsZS5leHBvcnRzID0geyBtYWtlU3ByaW5nLCBhcHBseVNwcmluZyB9O1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2V1bGVyL3NwcmluZy5qcyIsIi8qKlxuVGhlIGltcGxlbWVudGF0aW9uIG9mIHRoZSBFdWxlciBsYXlvdXQgYWxnb3JpdGhtXG4qL1xuXG5jb25zdCBMYXlvdXQgPSByZXF1aXJlKCcuLi9sYXlvdXQnKTtcbmNvbnN0IGFzc2lnbiA9IHJlcXVpcmUoJy4uL2Fzc2lnbicpO1xuY29uc3QgZGVmYXVsdHMgPSByZXF1aXJlKCcuL2RlZmF1bHRzJyk7XG5jb25zdCB7IHRpY2sgfSA9IHJlcXVpcmUoJy4vdGljaycpO1xuY29uc3QgeyBtYWtlUXVhZHRyZWUgfSA9IHJlcXVpcmUoJy4vcXVhZHRyZWUnKTtcbmNvbnN0IHsgbWFrZUJvZHkgfSA9IHJlcXVpcmUoJy4vYm9keScpO1xuY29uc3QgeyBtYWtlU3ByaW5nIH0gPSByZXF1aXJlKCcuL3NwcmluZycpO1xuY29uc3QgaXNGbiA9IGZuID0+IHR5cGVvZiBmbiA9PT0gJ2Z1bmN0aW9uJztcbmNvbnN0IGlzUGFyZW50ID0gbiA9PiBuLmlzUGFyZW50KCk7XG5jb25zdCBub3RJc1BhcmVudCA9IG4gPT4gIWlzUGFyZW50KG4pO1xuY29uc3QgaXNMb2NrZWQgPSBuID0+IG4ubG9ja2VkKCk7XG5jb25zdCBub3RJc0xvY2tlZCA9IG4gPT4gIWlzTG9ja2VkKG4pO1xuY29uc3QgaXNQYXJlbnRFZGdlID0gZSA9PiBpc1BhcmVudCggZS5zb3VyY2UoKSApIHx8IGlzUGFyZW50KCBlLnRhcmdldCgpICk7XG5jb25zdCBub3RJc1BhcmVudEVkZ2UgPSBlID0+ICFpc1BhcmVudEVkZ2UoZSk7XG5jb25zdCBnZXRCb2R5ID0gbiA9PiBuLnNjcmF0Y2goJ2V1bGVyJykuYm9keTtcbmNvbnN0IGdldE5vblBhcmVudERlc2NlbmRhbnRzID0gbiA9PiBpc1BhcmVudChuKSA/IG4uZGVzY2VuZGFudHMoKS5maWx0ZXIoIG5vdElzUGFyZW50ICkgOiBuO1xuXG5jb25zdCBnZXRTY3JhdGNoID0gZWwgPT4ge1xuICBsZXQgc2NyYXRjaCA9IGVsLnNjcmF0Y2goJ2V1bGVyJyk7XG5cbiAgaWYoICFzY3JhdGNoICl7XG4gICAgc2NyYXRjaCA9IHt9O1xuXG4gICAgZWwuc2NyYXRjaCgnZXVsZXInLCBzY3JhdGNoKTtcbiAgfVxuXG4gIHJldHVybiBzY3JhdGNoO1xufTtcblxuY29uc3Qgb3B0Rm4gPSAoIG9wdCwgZWxlICkgPT4ge1xuICBpZiggaXNGbiggb3B0ICkgKXtcbiAgICByZXR1cm4gb3B0KCBlbGUgKTtcbiAgfSBlbHNlIHtcbiAgICByZXR1cm4gb3B0O1xuICB9XG59O1xuXG5jbGFzcyBFdWxlciBleHRlbmRzIExheW91dCB7XG4gIGNvbnN0cnVjdG9yKCBvcHRpb25zICl7XG4gICAgc3VwZXIoIGFzc2lnbigge30sIGRlZmF1bHRzLCBvcHRpb25zICkgKTtcbiAgfVxuXG4gIHByZXJ1biggc3RhdGUgKXtcbiAgICBsZXQgcyA9IHN0YXRlO1xuXG4gICAgcy5xdWFkdHJlZSA9IG1ha2VRdWFkdHJlZSgpO1xuXG4gICAgbGV0IGJvZGllcyA9IHMuYm9kaWVzID0gW107XG5cbiAgICAvLyByZWd1bGFyIG5vZGVzXG4gICAgcy5ub2Rlcy5maWx0ZXIoIG4gPT4gbm90SXNQYXJlbnQobikgKS5mb3JFYWNoKCBuID0+IHtcbiAgICAgIGxldCBzY3JhdGNoID0gZ2V0U2NyYXRjaCggbiApO1xuXG4gICAgICBsZXQgYm9keSA9IG1ha2VCb2R5KHtcbiAgICAgICAgcG9zOiB7IHg6IHNjcmF0Y2gueCwgeTogc2NyYXRjaC55IH0sXG4gICAgICAgIG1hc3M6IG9wdEZuKCBzLm1hc3MsIG4gKSxcbiAgICAgICAgbG9ja2VkOiBzY3JhdGNoLmxvY2tlZFxuICAgICAgfSk7XG5cbiAgICAgIGJvZHkuX2N5Tm9kZSA9IG47XG5cbiAgICAgIHNjcmF0Y2guYm9keSA9IGJvZHk7XG5cbiAgICAgIGJvZHkuX3NjcmF0Y2ggPSBzY3JhdGNoO1xuXG4gICAgICBib2RpZXMucHVzaCggYm9keSApO1xuICAgIH0gKTtcblxuICAgIGxldCBzcHJpbmdzID0gcy5zcHJpbmdzID0gW107XG5cbiAgICAvLyByZWd1bGFyIGVkZ2Ugc3ByaW5nc1xuICAgIHMuZWRnZXMuZmlsdGVyKCBub3RJc1BhcmVudEVkZ2UgKS5mb3JFYWNoKCBlID0+IHtcbiAgICAgIGxldCBzcHJpbmcgPSBtYWtlU3ByaW5nKHtcbiAgICAgICAgc291cmNlOiBnZXRCb2R5KCBlLnNvdXJjZSgpICksXG4gICAgICAgIHRhcmdldDogZ2V0Qm9keSggZS50YXJnZXQoKSApLFxuICAgICAgICBsZW5ndGg6IG9wdEZuKCBzLnNwcmluZ0xlbmd0aCwgZSApLFxuICAgICAgICBjb2VmZjogb3B0Rm4oIHMuc3ByaW5nQ29lZmYsIGUgKVxuICAgICAgfSk7XG5cbiAgICAgIHNwcmluZy5fY3lFZGdlID0gZTtcblxuICAgICAgbGV0IHNjcmF0Y2ggPSBnZXRTY3JhdGNoKCBlICk7XG5cbiAgICAgIHNwcmluZy5fc2NyYXRjaCA9IHNjcmF0Y2g7XG5cbiAgICAgIHNjcmF0Y2guc3ByaW5nID0gc3ByaW5nO1xuXG4gICAgICBzcHJpbmdzLnB1c2goIHNwcmluZyApO1xuICAgIH0gKTtcblxuICAgIC8vIGNvbXBvdW5kIGVkZ2Ugc3ByaW5nc1xuICAgIHMuZWRnZXMuZmlsdGVyKCBpc1BhcmVudEVkZ2UgKS5mb3JFYWNoKCBlID0+IHtcbiAgICAgIGxldCBzb3VyY2VzID0gZ2V0Tm9uUGFyZW50RGVzY2VuZGFudHMoIGUuc291cmNlKCkgKTtcbiAgICAgIGxldCB0YXJnZXRzID0gZ2V0Tm9uUGFyZW50RGVzY2VuZGFudHMoIGUudGFyZ2V0KCkgKTtcblxuICAgICAgLy8ganVzdCBhZGQgb25lIHNwcmluZyBmb3IgcGVyZlxuICAgICAgc291cmNlcyA9IFsgc291cmNlc1swXSBdO1xuICAgICAgdGFyZ2V0cyA9IFsgdGFyZ2V0c1swXSBdO1xuXG4gICAgICBzb3VyY2VzLmZvckVhY2goIHNyYyA9PiB7XG4gICAgICAgIHRhcmdldHMuZm9yRWFjaCggdGd0ID0+IHtcbiAgICAgICAgICBzcHJpbmdzLnB1c2goIG1ha2VTcHJpbmcoe1xuICAgICAgICAgICAgc291cmNlOiBnZXRCb2R5KCBzcmMgKSxcbiAgICAgICAgICAgIHRhcmdldDogZ2V0Qm9keSggdGd0ICksXG4gICAgICAgICAgICBsZW5ndGg6IG9wdEZuKCBzLnNwcmluZ0xlbmd0aCwgZSApLFxuICAgICAgICAgICAgY29lZmY6IG9wdEZuKCBzLnNwcmluZ0NvZWZmLCBlIClcbiAgICAgICAgICB9KSApO1xuICAgICAgICB9ICk7XG4gICAgICB9ICk7XG4gICAgfSApO1xuICB9XG5cbiAgdGljayggc3RhdGUgKXtcbiAgICBsZXQgbW92ZW1lbnQgPSB0aWNrKCBzdGF0ZSApO1xuXG4gICAgbGV0IGlzRG9uZSA9IG1vdmVtZW50IDw9IHN0YXRlLm1vdmVtZW50VGhyZXNob2xkO1xuXG4gICAgcmV0dXJuIGlzRG9uZTtcbiAgfVxufVxuXG5tb2R1bGUuZXhwb3J0cyA9IEV1bGVyO1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2V1bGVyL2luZGV4LmpzIiwiY29uc3QgZGVmYXVsdHMgPSBPYmplY3QuZnJlZXplKHtcbiAgcG9zOiB7IHg6IDAsIHk6IDAgfSxcbiAgcHJldlBvczogeyB4OiAwLCB5OiAwIH0sXG4gIGZvcmNlOiB7IHg6IDAsIHk6IDAgfSxcbiAgdmVsb2NpdHk6IHsgeDogMCwgeTogMCB9LFxuICBtYXNzOiAxXG59KTtcblxuY29uc3QgY29weVZlYyA9IHYgPT4gKHsgeDogdi54LCB5OiB2LnkgfSk7XG5jb25zdCBnZXRWYWx1ZSA9ICggdmFsLCBkZWYgKSA9PiB2YWwgIT0gbnVsbCA/IHZhbCA6IGRlZjtcbmNvbnN0IGdldFZlYyA9ICggdmVjLCBkZWYgKSA9PiBjb3B5VmVjKCBnZXRWYWx1ZSggdmVjLCBkZWYgKSApO1xuXG5mdW5jdGlvbiBtYWtlQm9keSggb3B0cyApe1xuICBsZXQgYiA9IHt9O1xuXG4gIGIucG9zID0gZ2V0VmVjKCBvcHRzLnBvcywgZGVmYXVsdHMucG9zICk7XG4gIGIucHJldlBvcyA9IGdldFZlYyggb3B0cy5wcmV2UG9zLCBiLnBvcyApO1xuICBiLmZvcmNlID0gZ2V0VmVjKCBvcHRzLmZvcmNlLCBkZWZhdWx0cy5mb3JjZSApO1xuICBiLnZlbG9jaXR5ID0gZ2V0VmVjKCBvcHRzLnZlbG9jaXR5LCBkZWZhdWx0cy52ZWxvY2l0eSApO1xuICBiLm1hc3MgPSBvcHRzLm1hc3MgIT0gbnVsbCA/IG9wdHMubWFzcyA6IGRlZmF1bHRzLm1hc3M7XG4gIGIubG9ja2VkID0gb3B0cy5sb2NrZWQ7XG5cbiAgcmV0dXJuIGI7XG59XG5cbm1vZHVsZS5leHBvcnRzID0geyBtYWtlQm9keSB9O1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2V1bGVyL2JvZHkuanMiLCJjb25zdCBkZWZhdWx0cyA9IE9iamVjdC5mcmVlemUoe1xuICAvLyBUaGUgaWRlYWwgbGVndGggb2YgYSBzcHJpbmdcbiAgLy8gLSBUaGlzIGFjdHMgYXMgYSBoaW50IGZvciB0aGUgZWRnZSBsZW5ndGhcbiAgLy8gLSBUaGUgZWRnZSBsZW5ndGggY2FuIGJlIGxvbmdlciBvciBzaG9ydGVyIGlmIHRoZSBmb3JjZXMgYXJlIHNldCB0byBleHRyZW1lIHZhbHVlc1xuICBzcHJpbmdMZW5ndGg6IGVkZ2UgPT4gODAsXG5cbiAgLy8gSG9va2UncyBsYXcgY29lZmZpY2llbnRcbiAgLy8gLSBUaGUgdmFsdWUgcmFuZ2VzIG9uIFswLCAxXVxuICAvLyAtIExvd2VyIHZhbHVlcyBnaXZlIGxvb3NlciBzcHJpbmdzXG4gIC8vIC0gSGlnaGVyIHZhbHVlcyBnaXZlIHRpZ2h0ZXIgc3ByaW5nc1xuICBzcHJpbmdDb2VmZjogZWRnZSA9PiAwLjAwMDgsXG5cbiAgLy8gVGhlIG1hc3Mgb2YgdGhlIG5vZGUgaW4gdGhlIHBoeXNpY3Mgc2ltdWxhdGlvblxuICAvLyAtIFRoZSBtYXNzIGFmZmVjdHMgdGhlIGdyYXZpdHkgbm9kZSByZXB1bHNpb24vYXR0cmFjdGlvblxuICBtYXNzOiBub2RlID0+IDQsXG5cbiAgLy8gQ291bG9tYidzIGxhdyBjb2VmZmljaWVudFxuICAvLyAtIE1ha2VzIHRoZSBub2RlcyByZXBlbCBlYWNoIG90aGVyIGZvciBuZWdhdGl2ZSB2YWx1ZXNcbiAgLy8gLSBNYWtlcyB0aGUgbm9kZXMgYXR0cmFjdCBlYWNoIG90aGVyIGZvciBwb3NpdGl2ZSB2YWx1ZXNcbiAgZ3Jhdml0eTogLTEuMixcblxuICAvLyBBIGZvcmNlIHRoYXQgcHVsbHMgbm9kZXMgdG93YXJkcyB0aGUgb3JpZ2luICgwLCAwKVxuICAvLyBIaWdoZXIgdmFsdWVzIGtlZXAgdGhlIGNvbXBvbmVudHMgbGVzcyBzcHJlYWQgb3V0XG4gIHB1bGw6IDAuMDAxLFxuXG4gIC8vIFRoZXRhIGNvZWZmaWNpZW50IGZyb20gQmFybmVzLUh1dCBzaW11bGF0aW9uXG4gIC8vIC0gVmFsdWUgcmFuZ2VzIG9uIFswLCAxXVxuICAvLyAtIFBlcmZvcm1hbmNlIGlzIGJldHRlciB3aXRoIHNtYWxsZXIgdmFsdWVzXG4gIC8vIC0gVmVyeSBzbWFsbCB2YWx1ZXMgbWF5IG5vdCBjcmVhdGUgZW5vdWdoIGZvcmNlIHRvIGdpdmUgYSBnb29kIHJlc3VsdFxuICB0aGV0YTogMC42NjYsXG5cbiAgLy8gRnJpY3Rpb24gLyBkcmFnIGNvZWZmaWNpZW50IHRvIG1ha2UgdGhlIHN5c3RlbSBzdGFiaWxpc2Ugb3ZlciB0aW1lXG4gIGRyYWdDb2VmZjogMC4wMixcblxuICAvLyBXaGVuIHRoZSB0b3RhbCBvZiB0aGUgc3F1YXJlZCBwb3NpdGlvbiBkZWx0YXMgaXMgbGVzcyB0aGFuIHRoaXMgdmFsdWUsIHRoZSBzaW11bGF0aW9uIGVuZHNcbiAgbW92ZW1lbnRUaHJlc2hvbGQ6IDEsXG5cbiAgLy8gVGhlIGFtb3VudCBvZiB0aW1lIHBhc3NlZCBwZXIgdGlja1xuICAvLyAtIExhcmdlciB2YWx1ZXMgcmVzdWx0IGluIGZhc3RlciBydW50aW1lcyBidXQgbWlnaHQgc3ByZWFkIHRoaW5ncyBvdXQgdG9vIGZhclxuICAvLyAtIFNtYWxsZXIgdmFsdWVzIHByb2R1Y2UgbW9yZSBhY2N1cmF0ZSByZXN1bHRzXG4gIHRpbWVTdGVwOiAyMFxufSk7XG5cbm1vZHVsZS5leHBvcnRzID0gZGVmYXVsdHM7XG5cblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gLi9zcmMvZXVsZXIvZGVmYXVsdHMuanMiLCJjb25zdCBkZWZhdWx0Q29lZmYgPSAwLjAyO1xuXG5mdW5jdGlvbiBhcHBseURyYWcoIGJvZHksIG1hbnVhbERyYWdDb2VmZiApe1xuICBsZXQgZHJhZ0NvZWZmO1xuXG4gIGlmKCBtYW51YWxEcmFnQ29lZmYgIT0gbnVsbCApe1xuICAgIGRyYWdDb2VmZiA9IG1hbnVhbERyYWdDb2VmZjtcbiAgfSBlbHNlIGlmKCBib2R5LmRyYWdDb2VmZiAhPSBudWxsICl7XG4gICAgZHJhZ0NvZWZmID0gYm9keS5kcmFnQ29lZmY7XG4gIH0gZWxzZSB7XG4gICAgZHJhZ0NvZWZmID0gZGVmYXVsdENvZWZmO1xuICB9XG5cbiAgYm9keS5mb3JjZS54IC09IGRyYWdDb2VmZiAqIGJvZHkudmVsb2NpdHkueDtcbiAgYm9keS5mb3JjZS55IC09IGRyYWdDb2VmZiAqIGJvZHkudmVsb2NpdHkueTtcbn1cblxubW9kdWxlLmV4cG9ydHMgPSB7IGFwcGx5RHJhZyB9O1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2V1bGVyL2RyYWcuanMiLCIvLyB1c2UgZXVsZXIgbWV0aG9kIGZvciBmb3JjZSBpbnRlZ3JhdGlvbiBodHRwOi8vZW4ud2lraXBlZGlhLm9yZy93aWtpL0V1bGVyX21ldGhvZFxuLy8gcmV0dXJuIHN1bSBvZiBzcXVhcmVkIHBvc2l0aW9uIGRlbHRhc1xuZnVuY3Rpb24gaW50ZWdyYXRlKCBib2RpZXMsIHRpbWVTdGVwICl7XG4gIHZhciBkeCA9IDAsIHR4ID0gMCxcbiAgICAgIGR5ID0gMCwgdHkgPSAwLFxuICAgICAgaSxcbiAgICAgIG1heCA9IGJvZGllcy5sZW5ndGg7XG5cbiAgaWYgKG1heCA9PT0gMCkge1xuICAgIHJldHVybiAwO1xuICB9XG5cbiAgZm9yIChpID0gMDsgaSA8IG1heDsgKytpKSB7XG4gICAgdmFyIGJvZHkgPSBib2RpZXNbaV0sXG4gICAgICAgIGNvZWZmID0gdGltZVN0ZXAgLyBib2R5Lm1hc3M7XG5cbiAgICBpZiggYm9keS5ncmFiYmVkICl7IGNvbnRpbnVlOyB9XG5cbiAgICBpZiggYm9keS5sb2NrZWQgKXtcbiAgICAgIGJvZHkudmVsb2NpdHkueCA9IDA7XG4gICAgICBib2R5LnZlbG9jaXR5LnkgPSAwO1xuICAgIH0gZWxzZSB7XG4gICAgICBib2R5LnZlbG9jaXR5LnggKz0gY29lZmYgKiBib2R5LmZvcmNlLng7XG4gICAgICBib2R5LnZlbG9jaXR5LnkgKz0gY29lZmYgKiBib2R5LmZvcmNlLnk7XG4gICAgfVxuXG4gICAgdmFyIHZ4ID0gYm9keS52ZWxvY2l0eS54LFxuICAgICAgICB2eSA9IGJvZHkudmVsb2NpdHkueSxcbiAgICAgICAgdiA9IE1hdGguc3FydCh2eCAqIHZ4ICsgdnkgKiB2eSk7XG5cbiAgICBpZiAodiA+IDEpIHtcbiAgICAgIGJvZHkudmVsb2NpdHkueCA9IHZ4IC8gdjtcbiAgICAgIGJvZHkudmVsb2NpdHkueSA9IHZ5IC8gdjtcbiAgICB9XG5cbiAgICBkeCA9IHRpbWVTdGVwICogYm9keS52ZWxvY2l0eS54O1xuICAgIGR5ID0gdGltZVN0ZXAgKiBib2R5LnZlbG9jaXR5Lnk7XG5cbiAgICBib2R5LnBvcy54ICs9IGR4O1xuICAgIGJvZHkucG9zLnkgKz0gZHk7XG5cbiAgICB0eCArPSBNYXRoLmFicyhkeCk7IHR5ICs9IE1hdGguYWJzKGR5KTtcbiAgfVxuXG4gIHJldHVybiAodHggKiB0eCArIHR5ICogdHkpL21heDtcbn1cblxubW9kdWxlLmV4cG9ydHMgPSB7IGludGVncmF0ZSB9O1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2V1bGVyL2ludGVncmF0ZS5qcyIsIi8vIGltcGwgb2YgYmFybmVzIGh1dFxuLy8gaHR0cDovL3d3dy5lZWNzLmJlcmtlbGV5LmVkdS9+ZGVtbWVsL2NzMjY3L2xlY3R1cmUyNi9sZWN0dXJlMjYuaHRtbFxuLy8gaHR0cDovL2VuLndpa2lwZWRpYS5vcmcvd2lraS9CYXJuZXMlRTIlODAlOTNIdXRfc2ltdWxhdGlvblxuXG5jb25zdCBOb2RlID0gcmVxdWlyZSgnLi9ub2RlJyk7XG5jb25zdCBJbnNlcnRTdGFjayA9IHJlcXVpcmUoJy4vaW5zZXJ0U3RhY2snKTtcblxuY29uc3QgcmVzZXRWZWMgPSB2ID0+IHsgdi54ID0gMDsgdi55ID0gMDsgfTtcblxuY29uc3QgaXNTYW1lUG9zaXRpb24gPSAocDEsIHAyKSA9PiB7XG4gIGxldCB0aHJlc2hvbGQgPSAxZS04O1xuICBsZXQgZHggPSBNYXRoLmFicyhwMS54IC0gcDIueCk7XG4gIGxldCBkeSA9IE1hdGguYWJzKHAxLnkgLSBwMi55KTtcblxuICByZXR1cm4gZHggPCB0aHJlc2hvbGQgJiYgZHkgPCB0aHJlc2hvbGQ7XG59O1xuXG5mdW5jdGlvbiBtYWtlUXVhZHRyZWUoKXtcbiAgbGV0IHVwZGF0ZVF1ZXVlID0gW10sXG4gICAgaW5zZXJ0U3RhY2sgPSBuZXcgSW5zZXJ0U3RhY2soKSxcbiAgICBub2Rlc0NhY2hlID0gW10sXG4gICAgY3VycmVudEluQ2FjaGUgPSAwLFxuICAgIHJvb3QgPSBuZXdOb2RlKCk7XG5cbiAgZnVuY3Rpb24gbmV3Tm9kZSgpIHtcbiAgICAvLyBUbyBhdm9pZCBwcmVzc3VyZSBvbiBHQyB3ZSByZXVzZSBub2Rlcy5cbiAgICBsZXQgbm9kZSA9IG5vZGVzQ2FjaGVbY3VycmVudEluQ2FjaGVdO1xuICAgIGlmIChub2RlKSB7XG4gICAgICBub2RlLnF1YWQwID0gbnVsbDtcbiAgICAgIG5vZGUucXVhZDEgPSBudWxsO1xuICAgICAgbm9kZS5xdWFkMiA9IG51bGw7XG4gICAgICBub2RlLnF1YWQzID0gbnVsbDtcbiAgICAgIG5vZGUuYm9keSA9IG51bGw7XG4gICAgICBub2RlLm1hc3MgPSBub2RlLm1hc3NYID0gbm9kZS5tYXNzWSA9IDA7XG4gICAgICBub2RlLmxlZnQgPSBub2RlLnJpZ2h0ID0gbm9kZS50b3AgPSBub2RlLmJvdHRvbSA9IDA7XG4gICAgfSBlbHNlIHtcbiAgICAgIG5vZGUgPSBuZXcgTm9kZSgpO1xuICAgICAgbm9kZXNDYWNoZVtjdXJyZW50SW5DYWNoZV0gPSBub2RlO1xuICAgIH1cblxuICAgICsrY3VycmVudEluQ2FjaGU7XG4gICAgcmV0dXJuIG5vZGU7XG4gIH1cblxuICBmdW5jdGlvbiB1cGRhdGUoIHNvdXJjZUJvZHksIGdyYXZpdHksIHRoZXRhLCBwdWxsICkge1xuICAgIGxldCBxdWV1ZSA9IHVwZGF0ZVF1ZXVlLFxuICAgICAgdixcbiAgICAgIGR4LFxuICAgICAgZHksXG4gICAgICByLCBmeCA9IDAsXG4gICAgICBmeSA9IDAsXG4gICAgICBxdWV1ZUxlbmd0aCA9IDEsXG4gICAgICBzaGlmdElkeCA9IDAsXG4gICAgICBwdXNoSWR4ID0gMTtcblxuICAgIHF1ZXVlWzBdID0gcm9vdDtcblxuICAgIHJlc2V0VmVjKCBzb3VyY2VCb2R5LmZvcmNlICk7XG5cbiAgICBsZXQgcHggPSAtc291cmNlQm9keS5wb3MueDtcbiAgICBsZXQgcHkgPSAtc291cmNlQm9keS5wb3MueTtcbiAgICBsZXQgcHIgPSBNYXRoLnNxcnQocHggKiBweCArIHB5ICogcHkpO1xuICAgIGxldCBwdiA9IHNvdXJjZUJvZHkubWFzcyAqIHB1bGwgLyBwcjtcblxuICAgIGZ4ICs9IHB2ICogcHg7XG4gICAgZnkgKz0gcHYgKiBweTtcblxuICAgIHdoaWxlIChxdWV1ZUxlbmd0aCkge1xuICAgICAgbGV0IG5vZGUgPSBxdWV1ZVtzaGlmdElkeF0sXG4gICAgICAgIGJvZHkgPSBub2RlLmJvZHk7XG5cbiAgICAgIHF1ZXVlTGVuZ3RoIC09IDE7XG4gICAgICBzaGlmdElkeCArPSAxO1xuICAgICAgbGV0IGRpZmZlcmVudEJvZHkgPSAoYm9keSAhPT0gc291cmNlQm9keSk7XG4gICAgICBpZiAoYm9keSAmJiBkaWZmZXJlbnRCb2R5KSB7XG4gICAgICAgIC8vIElmIHRoZSBjdXJyZW50IG5vZGUgaXMgYSBsZWFmIG5vZGUgKGFuZCBpdCBpcyBub3Qgc291cmNlIGJvZHkpLFxuICAgICAgICAvLyBjYWxjdWxhdGUgdGhlIGZvcmNlIGV4ZXJ0ZWQgYnkgdGhlIGN1cnJlbnQgbm9kZSBvbiBib2R5LCBhbmQgYWRkIHRoaXNcbiAgICAgICAgLy8gYW1vdW50IHRvIGJvZHkncyBuZXQgZm9yY2UuXG4gICAgICAgIGR4ID0gYm9keS5wb3MueCAtIHNvdXJjZUJvZHkucG9zLng7XG4gICAgICAgIGR5ID0gYm9keS5wb3MueSAtIHNvdXJjZUJvZHkucG9zLnk7XG4gICAgICAgIHIgPSBNYXRoLnNxcnQoZHggKiBkeCArIGR5ICogZHkpO1xuXG4gICAgICAgIGlmIChyID09PSAwKSB7XG4gICAgICAgICAgLy8gUG9vciBtYW4ncyBwcm90ZWN0aW9uIGFnYWluc3QgemVybyBkaXN0YW5jZS5cbiAgICAgICAgICBkeCA9IChNYXRoLnJhbmRvbSgpIC0gMC41KSAvIDUwO1xuICAgICAgICAgIGR5ID0gKE1hdGgucmFuZG9tKCkgLSAwLjUpIC8gNTA7XG4gICAgICAgICAgciA9IE1hdGguc3FydChkeCAqIGR4ICsgZHkgKiBkeSk7XG4gICAgICAgIH1cblxuICAgICAgICAvLyBUaGlzIGlzIHN0YW5kYXJkIGdyYXZpdGlvbiBmb3JjZSBjYWxjdWxhdGlvbiBidXQgd2UgZGl2aWRlXG4gICAgICAgIC8vIGJ5IHJeMyB0byBzYXZlIHR3byBvcGVyYXRpb25zIHdoZW4gbm9ybWFsaXppbmcgZm9yY2UgdmVjdG9yLlxuICAgICAgICB2ID0gZ3Jhdml0eSAqIGJvZHkubWFzcyAqIHNvdXJjZUJvZHkubWFzcyAvIChyICogciAqIHIpO1xuICAgICAgICBmeCArPSB2ICogZHg7XG4gICAgICAgIGZ5ICs9IHYgKiBkeTtcbiAgICAgIH0gZWxzZSBpZiAoZGlmZmVyZW50Qm9keSkge1xuICAgICAgICAvLyBPdGhlcndpc2UsIGNhbGN1bGF0ZSB0aGUgcmF0aW8gcyAvIHIsICB3aGVyZSBzIGlzIHRoZSB3aWR0aCBvZiB0aGUgcmVnaW9uXG4gICAgICAgIC8vIHJlcHJlc2VudGVkIGJ5IHRoZSBpbnRlcm5hbCBub2RlLCBhbmQgciBpcyB0aGUgZGlzdGFuY2UgYmV0d2VlbiB0aGUgYm9keVxuICAgICAgICAvLyBhbmQgdGhlIG5vZGUncyBjZW50ZXItb2YtbWFzc1xuICAgICAgICBkeCA9IG5vZGUubWFzc1ggLyBub2RlLm1hc3MgLSBzb3VyY2VCb2R5LnBvcy54O1xuICAgICAgICBkeSA9IG5vZGUubWFzc1kgLyBub2RlLm1hc3MgLSBzb3VyY2VCb2R5LnBvcy55O1xuICAgICAgICByID0gTWF0aC5zcXJ0KGR4ICogZHggKyBkeSAqIGR5KTtcblxuICAgICAgICBpZiAociA9PT0gMCkge1xuICAgICAgICAgIC8vIFNvcnJ5IGFib3V0IGNvZGUgZHVwbHVjYXRpb24uIEkgZG9uJ3Qgd2FudCB0byBjcmVhdGUgbWFueSBmdW5jdGlvbnNcbiAgICAgICAgICAvLyByaWdodCBhd2F5LiBKdXN0IHdhbnQgdG8gc2VlIHBlcmZvcm1hbmNlIGZpcnN0LlxuICAgICAgICAgIGR4ID0gKE1hdGgucmFuZG9tKCkgLSAwLjUpIC8gNTA7XG4gICAgICAgICAgZHkgPSAoTWF0aC5yYW5kb20oKSAtIDAuNSkgLyA1MDtcbiAgICAgICAgICByID0gTWF0aC5zcXJ0KGR4ICogZHggKyBkeSAqIGR5KTtcbiAgICAgICAgfVxuICAgICAgICAvLyBJZiBzIC8gciA8IM64LCB0cmVhdCB0aGlzIGludGVybmFsIG5vZGUgYXMgYSBzaW5nbGUgYm9keSwgYW5kIGNhbGN1bGF0ZSB0aGVcbiAgICAgICAgLy8gZm9yY2UgaXQgZXhlcnRzIG9uIHNvdXJjZUJvZHksIGFuZCBhZGQgdGhpcyBhbW91bnQgdG8gc291cmNlQm9keSdzIG5ldCBmb3JjZS5cbiAgICAgICAgaWYgKChub2RlLnJpZ2h0IC0gbm9kZS5sZWZ0KSAvIHIgPCB0aGV0YSkge1xuICAgICAgICAgIC8vIGluIHRoZSBpZiBzdGF0ZW1lbnQgYWJvdmUgd2UgY29uc2lkZXIgbm9kZSdzIHdpZHRoIG9ubHlcbiAgICAgICAgICAvLyBiZWNhdXNlIHRoZSByZWdpb24gd2FzIHNxdWFyaWZpZWQgZHVyaW5nIHRyZWUgY3JlYXRpb24uXG4gICAgICAgICAgLy8gVGh1cyB0aGVyZSBpcyBubyBkaWZmZXJlbmNlIGJldHdlZW4gdXNpbmcgd2lkdGggb3IgaGVpZ2h0LlxuICAgICAgICAgIHYgPSBncmF2aXR5ICogbm9kZS5tYXNzICogc291cmNlQm9keS5tYXNzIC8gKHIgKiByICogcik7XG4gICAgICAgICAgZnggKz0gdiAqIGR4O1xuICAgICAgICAgIGZ5ICs9IHYgKiBkeTtcbiAgICAgICAgfSBlbHNlIHtcbiAgICAgICAgICAvLyBPdGhlcndpc2UsIHJ1biB0aGUgcHJvY2VkdXJlIHJlY3Vyc2l2ZWx5IG9uIGVhY2ggb2YgdGhlIGN1cnJlbnQgbm9kZSdzIGNoaWxkcmVuLlxuXG4gICAgICAgICAgLy8gSSBpbnRlbnRpb25hbGx5IHVuZm9sZGVkIHRoaXMgbG9vcCwgdG8gc2F2ZSBzZXZlcmFsIENQVSBjeWNsZXMuXG4gICAgICAgICAgaWYgKG5vZGUucXVhZDApIHtcbiAgICAgICAgICAgIHF1ZXVlW3B1c2hJZHhdID0gbm9kZS5xdWFkMDtcbiAgICAgICAgICAgIHF1ZXVlTGVuZ3RoICs9IDE7XG4gICAgICAgICAgICBwdXNoSWR4ICs9IDE7XG4gICAgICAgICAgfVxuICAgICAgICAgIGlmIChub2RlLnF1YWQxKSB7XG4gICAgICAgICAgICBxdWV1ZVtwdXNoSWR4XSA9IG5vZGUucXVhZDE7XG4gICAgICAgICAgICBxdWV1ZUxlbmd0aCArPSAxO1xuICAgICAgICAgICAgcHVzaElkeCArPSAxO1xuICAgICAgICAgIH1cbiAgICAgICAgICBpZiAobm9kZS5xdWFkMikge1xuICAgICAgICAgICAgcXVldWVbcHVzaElkeF0gPSBub2RlLnF1YWQyO1xuICAgICAgICAgICAgcXVldWVMZW5ndGggKz0gMTtcbiAgICAgICAgICAgIHB1c2hJZHggKz0gMTtcbiAgICAgICAgICB9XG4gICAgICAgICAgaWYgKG5vZGUucXVhZDMpIHtcbiAgICAgICAgICAgIHF1ZXVlW3B1c2hJZHhdID0gbm9kZS5xdWFkMztcbiAgICAgICAgICAgIHF1ZXVlTGVuZ3RoICs9IDE7XG4gICAgICAgICAgICBwdXNoSWR4ICs9IDE7XG4gICAgICAgICAgfVxuICAgICAgICB9XG4gICAgICB9XG4gICAgfVxuXG4gICAgc291cmNlQm9keS5mb3JjZS54ICs9IGZ4O1xuICAgIHNvdXJjZUJvZHkuZm9yY2UueSArPSBmeTtcbiAgfVxuXG4gIGZ1bmN0aW9uIGluc2VydEJvZGllcyhib2RpZXMpIHtcbiAgICBpZiggYm9kaWVzLmxlbmd0aCA9PT0gMCApeyByZXR1cm47IH1cblxuICAgIGxldCB4MSA9IE51bWJlci5NQVhfVkFMVUUsXG4gICAgICB5MSA9IE51bWJlci5NQVhfVkFMVUUsXG4gICAgICB4MiA9IE51bWJlci5NSU5fVkFMVUUsXG4gICAgICB5MiA9IE51bWJlci5NSU5fVkFMVUUsXG4gICAgICBpLFxuICAgICAgbWF4ID0gYm9kaWVzLmxlbmd0aDtcblxuICAgIC8vIFRvIHJlZHVjZSBxdWFkIHRyZWUgZGVwdGggd2UgYXJlIGxvb2tpbmcgZm9yIGV4YWN0IGJvdW5kaW5nIGJveCBvZiBhbGwgcGFydGljbGVzLlxuICAgIGkgPSBtYXg7XG4gICAgd2hpbGUgKGktLSkge1xuICAgICAgbGV0IHggPSBib2RpZXNbaV0ucG9zLng7XG4gICAgICBsZXQgeSA9IGJvZGllc1tpXS5wb3MueTtcbiAgICAgIGlmICh4IDwgeDEpIHtcbiAgICAgICAgeDEgPSB4O1xuICAgICAgfVxuICAgICAgaWYgKHggPiB4Mikge1xuICAgICAgICB4MiA9IHg7XG4gICAgICB9XG4gICAgICBpZiAoeSA8IHkxKSB7XG4gICAgICAgIHkxID0geTtcbiAgICAgIH1cbiAgICAgIGlmICh5ID4geTIpIHtcbiAgICAgICAgeTIgPSB5O1xuICAgICAgfVxuICAgIH1cblxuICAgIC8vIFNxdWFyaWZ5IHRoZSBib3VuZHMuXG4gICAgbGV0IGR4ID0geDIgLSB4MSxcbiAgICAgIGR5ID0geTIgLSB5MTtcbiAgICBpZiAoZHggPiBkeSkge1xuICAgICAgeTIgPSB5MSArIGR4O1xuICAgIH0gZWxzZSB7XG4gICAgICB4MiA9IHgxICsgZHk7XG4gICAgfVxuXG4gICAgY3VycmVudEluQ2FjaGUgPSAwO1xuICAgIHJvb3QgPSBuZXdOb2RlKCk7XG4gICAgcm9vdC5sZWZ0ID0geDE7XG4gICAgcm9vdC5yaWdodCA9IHgyO1xuICAgIHJvb3QudG9wID0geTE7XG4gICAgcm9vdC5ib3R0b20gPSB5MjtcblxuICAgIGkgPSBtYXggLSAxO1xuICAgIGlmIChpID49IDApIHtcbiAgICAgIHJvb3QuYm9keSA9IGJvZGllc1tpXTtcbiAgICB9XG4gICAgd2hpbGUgKGktLSkge1xuICAgICAgaW5zZXJ0KGJvZGllc1tpXSwgcm9vdCk7XG4gICAgfVxuICB9XG5cbiAgZnVuY3Rpb24gaW5zZXJ0KG5ld0JvZHkpIHtcbiAgICBpbnNlcnRTdGFjay5yZXNldCgpO1xuICAgIGluc2VydFN0YWNrLnB1c2gocm9vdCwgbmV3Qm9keSk7XG5cbiAgICB3aGlsZSAoIWluc2VydFN0YWNrLmlzRW1wdHkoKSkge1xuICAgICAgbGV0IHN0YWNrSXRlbSA9IGluc2VydFN0YWNrLnBvcCgpLFxuICAgICAgICBub2RlID0gc3RhY2tJdGVtLm5vZGUsXG4gICAgICAgIGJvZHkgPSBzdGFja0l0ZW0uYm9keTtcblxuICAgICAgaWYgKCFub2RlLmJvZHkpIHtcbiAgICAgICAgLy8gVGhpcyBpcyBpbnRlcm5hbCBub2RlLiBVcGRhdGUgdGhlIHRvdGFsIG1hc3Mgb2YgdGhlIG5vZGUgYW5kIGNlbnRlci1vZi1tYXNzLlxuICAgICAgICBsZXQgeCA9IGJvZHkucG9zLng7XG4gICAgICAgIGxldCB5ID0gYm9keS5wb3MueTtcbiAgICAgICAgbm9kZS5tYXNzID0gbm9kZS5tYXNzICsgYm9keS5tYXNzO1xuICAgICAgICBub2RlLm1hc3NYID0gbm9kZS5tYXNzWCArIGJvZHkubWFzcyAqIHg7XG4gICAgICAgIG5vZGUubWFzc1kgPSBub2RlLm1hc3NZICsgYm9keS5tYXNzICogeTtcblxuICAgICAgICAvLyBSZWN1cnNpdmVseSBpbnNlcnQgdGhlIGJvZHkgaW4gdGhlIGFwcHJvcHJpYXRlIHF1YWRyYW50LlxuICAgICAgICAvLyBCdXQgZmlyc3QgZmluZCB0aGUgYXBwcm9wcmlhdGUgcXVhZHJhbnQuXG4gICAgICAgIGxldCBxdWFkSWR4ID0gMCwgLy8gQXNzdW1lIHdlIGFyZSBpbiB0aGUgMCdzIHF1YWQuXG4gICAgICAgICAgbGVmdCA9IG5vZGUubGVmdCxcbiAgICAgICAgICByaWdodCA9IChub2RlLnJpZ2h0ICsgbGVmdCkgLyAyLFxuICAgICAgICAgIHRvcCA9IG5vZGUudG9wLFxuICAgICAgICAgIGJvdHRvbSA9IChub2RlLmJvdHRvbSArIHRvcCkgLyAyO1xuXG4gICAgICAgIGlmICh4ID4gcmlnaHQpIHsgLy8gc29tZXdoZXJlIGluIHRoZSBlYXN0ZXJuIHBhcnQuXG4gICAgICAgICAgcXVhZElkeCA9IHF1YWRJZHggKyAxO1xuICAgICAgICAgIGxlZnQgPSByaWdodDtcbiAgICAgICAgICByaWdodCA9IG5vZGUucmlnaHQ7XG4gICAgICAgIH1cbiAgICAgICAgaWYgKHkgPiBib3R0b20pIHsgLy8gYW5kIGluIHNvdXRoLlxuICAgICAgICAgIHF1YWRJZHggPSBxdWFkSWR4ICsgMjtcbiAgICAgICAgICB0b3AgPSBib3R0b207XG4gICAgICAgICAgYm90dG9tID0gbm9kZS5ib3R0b207XG4gICAgICAgIH1cblxuICAgICAgICBsZXQgY2hpbGQgPSBnZXRDaGlsZChub2RlLCBxdWFkSWR4KTtcbiAgICAgICAgaWYgKCFjaGlsZCkge1xuICAgICAgICAgIC8vIFRoZSBub2RlIGlzIGludGVybmFsIGJ1dCB0aGlzIHF1YWRyYW50IGlzIG5vdCB0YWtlbi4gQWRkXG4gICAgICAgICAgLy8gc3Vibm9kZSB0byBpdC5cbiAgICAgICAgICBjaGlsZCA9IG5ld05vZGUoKTtcbiAgICAgICAgICBjaGlsZC5sZWZ0ID0gbGVmdDtcbiAgICAgICAgICBjaGlsZC50b3AgPSB0b3A7XG4gICAgICAgICAgY2hpbGQucmlnaHQgPSByaWdodDtcbiAgICAgICAgICBjaGlsZC5ib3R0b20gPSBib3R0b207XG4gICAgICAgICAgY2hpbGQuYm9keSA9IGJvZHk7XG5cbiAgICAgICAgICBzZXRDaGlsZChub2RlLCBxdWFkSWR4LCBjaGlsZCk7XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgLy8gY29udGludWUgc2VhcmNoaW5nIGluIHRoaXMgcXVhZHJhbnQuXG4gICAgICAgICAgaW5zZXJ0U3RhY2sucHVzaChjaGlsZCwgYm9keSk7XG4gICAgICAgIH1cbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIC8vIFdlIGFyZSB0cnlpbmcgdG8gYWRkIHRvIHRoZSBsZWFmIG5vZGUuXG4gICAgICAgIC8vIFdlIGhhdmUgdG8gY29udmVydCBjdXJyZW50IGxlYWYgaW50byBpbnRlcm5hbCBub2RlXG4gICAgICAgIC8vIGFuZCBjb250aW51ZSBhZGRpbmcgdHdvIG5vZGVzLlxuICAgICAgICBsZXQgb2xkQm9keSA9IG5vZGUuYm9keTtcbiAgICAgICAgbm9kZS5ib2R5ID0gbnVsbDsgLy8gaW50ZXJuYWwgbm9kZXMgZG8gbm90IGNhcnkgYm9kaWVzXG5cbiAgICAgICAgaWYgKGlzU2FtZVBvc2l0aW9uKG9sZEJvZHkucG9zLCBib2R5LnBvcykpIHtcbiAgICAgICAgICAvLyBQcmV2ZW50IGluZmluaXRlIHN1YmRpdmlzaW9uIGJ5IGJ1bXBpbmcgb25lIG5vZGVcbiAgICAgICAgICAvLyBhbnl3aGVyZSBpbiB0aGlzIHF1YWRyYW50XG4gICAgICAgICAgbGV0IHJldHJpZXNDb3VudCA9IDM7XG4gICAgICAgICAgZG8ge1xuICAgICAgICAgICAgbGV0IG9mZnNldCA9IE1hdGgucmFuZG9tKCk7XG4gICAgICAgICAgICBsZXQgZHggPSAobm9kZS5yaWdodCAtIG5vZGUubGVmdCkgKiBvZmZzZXQ7XG4gICAgICAgICAgICBsZXQgZHkgPSAobm9kZS5ib3R0b20gLSBub2RlLnRvcCkgKiBvZmZzZXQ7XG5cbiAgICAgICAgICAgIG9sZEJvZHkucG9zLnggPSBub2RlLmxlZnQgKyBkeDtcbiAgICAgICAgICAgIG9sZEJvZHkucG9zLnkgPSBub2RlLnRvcCArIGR5O1xuICAgICAgICAgICAgcmV0cmllc0NvdW50IC09IDE7XG4gICAgICAgICAgICAvLyBNYWtlIHN1cmUgd2UgZG9uJ3QgYnVtcCBpdCBvdXQgb2YgdGhlIGJveC4gSWYgd2UgZG8sIG5leHQgaXRlcmF0aW9uIHNob3VsZCBmaXggaXRcbiAgICAgICAgICB9IHdoaWxlIChyZXRyaWVzQ291bnQgPiAwICYmIGlzU2FtZVBvc2l0aW9uKG9sZEJvZHkucG9zLCBib2R5LnBvcykpO1xuXG4gICAgICAgICAgaWYgKHJldHJpZXNDb3VudCA9PT0gMCAmJiBpc1NhbWVQb3NpdGlvbihvbGRCb2R5LnBvcywgYm9keS5wb3MpKSB7XG4gICAgICAgICAgICAvLyBUaGlzIGlzIHZlcnkgYmFkLCB3ZSByYW4gb3V0IG9mIHByZWNpc2lvbi5cbiAgICAgICAgICAgIC8vIGlmIHdlIGRvIG5vdCByZXR1cm4gZnJvbSB0aGUgbWV0aG9kIHdlJ2xsIGdldCBpbnRvXG4gICAgICAgICAgICAvLyBpbmZpbml0ZSBsb29wIGhlcmUuIFNvIHdlIHNhY3JpZmljZSBjb3JyZWN0bmVzcyBvZiBsYXlvdXQsIGFuZCBrZWVwIHRoZSBhcHAgcnVubmluZ1xuICAgICAgICAgICAgLy8gTmV4dCBsYXlvdXQgaXRlcmF0aW9uIHNob3VsZCBnZXQgbGFyZ2VyIGJvdW5kaW5nIGJveCBpbiB0aGUgZmlyc3Qgc3RlcCBhbmQgZml4IHRoaXNcbiAgICAgICAgICAgIHJldHVybjtcbiAgICAgICAgICB9XG4gICAgICAgIH1cbiAgICAgICAgLy8gTmV4dCBpdGVyYXRpb24gc2hvdWxkIHN1YmRpdmlkZSBub2RlIGZ1cnRoZXIuXG4gICAgICAgIGluc2VydFN0YWNrLnB1c2gobm9kZSwgb2xkQm9keSk7XG4gICAgICAgIGluc2VydFN0YWNrLnB1c2gobm9kZSwgYm9keSk7XG4gICAgICB9XG4gICAgfVxuICB9XG5cbiAgcmV0dXJuIHtcbiAgICBpbnNlcnRCb2RpZXM6IGluc2VydEJvZGllcyxcbiAgICB1cGRhdGVCb2R5Rm9yY2U6IHVwZGF0ZVxuICB9O1xufVxuXG5mdW5jdGlvbiBnZXRDaGlsZChub2RlLCBpZHgpIHtcbiAgaWYgKGlkeCA9PT0gMCkgcmV0dXJuIG5vZGUucXVhZDA7XG4gIGlmIChpZHggPT09IDEpIHJldHVybiBub2RlLnF1YWQxO1xuICBpZiAoaWR4ID09PSAyKSByZXR1cm4gbm9kZS5xdWFkMjtcbiAgaWYgKGlkeCA9PT0gMykgcmV0dXJuIG5vZGUucXVhZDM7XG4gIHJldHVybiBudWxsO1xufVxuXG5mdW5jdGlvbiBzZXRDaGlsZChub2RlLCBpZHgsIGNoaWxkKSB7XG4gIGlmIChpZHggPT09IDApIG5vZGUucXVhZDAgPSBjaGlsZDtcbiAgZWxzZSBpZiAoaWR4ID09PSAxKSBub2RlLnF1YWQxID0gY2hpbGQ7XG4gIGVsc2UgaWYgKGlkeCA9PT0gMikgbm9kZS5xdWFkMiA9IGNoaWxkO1xuICBlbHNlIGlmIChpZHggPT09IDMpIG5vZGUucXVhZDMgPSBjaGlsZDtcbn1cblxubW9kdWxlLmV4cG9ydHMgPSB7IG1ha2VRdWFkdHJlZSB9O1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2V1bGVyL3F1YWR0cmVlL2luZGV4LmpzIiwibW9kdWxlLmV4cG9ydHMgPSBJbnNlcnRTdGFjaztcblxuLyoqXG4gKiBPdXIgaW1wbG1lbnRhdGlvbiBvZiBRdWFkVHJlZSBpcyBub24tcmVjdXJzaXZlIHRvIGF2b2lkIEdDIGhpdFxuICogVGhpcyBkYXRhIHN0cnVjdHVyZSByZXByZXNlbnQgc3RhY2sgb2YgZWxlbWVudHNcbiAqIHdoaWNoIHdlIGFyZSB0cnlpbmcgdG8gaW5zZXJ0IGludG8gcXVhZCB0cmVlLlxuICovXG5mdW5jdGlvbiBJbnNlcnRTdGFjayAoKSB7XG4gICAgdGhpcy5zdGFjayA9IFtdO1xuICAgIHRoaXMucG9wSWR4ID0gMDtcbn1cblxuSW5zZXJ0U3RhY2sucHJvdG90eXBlID0ge1xuICAgIGlzRW1wdHk6IGZ1bmN0aW9uKCkge1xuICAgICAgICByZXR1cm4gdGhpcy5wb3BJZHggPT09IDA7XG4gICAgfSxcbiAgICBwdXNoOiBmdW5jdGlvbiAobm9kZSwgYm9keSkge1xuICAgICAgICBsZXQgaXRlbSA9IHRoaXMuc3RhY2tbdGhpcy5wb3BJZHhdO1xuICAgICAgICBpZiAoIWl0ZW0pIHtcbiAgICAgICAgICAgIC8vIHdlIGFyZSB0cnlpbmcgdG8gYXZvaWQgbWVtb3J5IHByZXNzdWU6IGNyZWF0ZSBuZXcgZWxlbWVudFxuICAgICAgICAgICAgLy8gb25seSB3aGVuIGFic29sdXRlbHkgbmVjZXNzYXJ5XG4gICAgICAgICAgICB0aGlzLnN0YWNrW3RoaXMucG9wSWR4XSA9IG5ldyBJbnNlcnRTdGFja0VsZW1lbnQobm9kZSwgYm9keSk7XG4gICAgICAgIH0gZWxzZSB7XG4gICAgICAgICAgICBpdGVtLm5vZGUgPSBub2RlO1xuICAgICAgICAgICAgaXRlbS5ib2R5ID0gYm9keTtcbiAgICAgICAgfVxuICAgICAgICArK3RoaXMucG9wSWR4O1xuICAgIH0sXG4gICAgcG9wOiBmdW5jdGlvbiAoKSB7XG4gICAgICAgIGlmICh0aGlzLnBvcElkeCA+IDApIHtcbiAgICAgICAgICAgIHJldHVybiB0aGlzLnN0YWNrWy0tdGhpcy5wb3BJZHhdO1xuICAgICAgICB9XG4gICAgfSxcbiAgICByZXNldDogZnVuY3Rpb24gKCkge1xuICAgICAgICB0aGlzLnBvcElkeCA9IDA7XG4gICAgfVxufTtcblxuZnVuY3Rpb24gSW5zZXJ0U3RhY2tFbGVtZW50KG5vZGUsIGJvZHkpIHtcbiAgICB0aGlzLm5vZGUgPSBub2RlOyAvLyBRdWFkVHJlZSBub2RlXG4gICAgdGhpcy5ib2R5ID0gYm9keTsgLy8gcGh5c2ljYWwgYm9keSB3aGljaCBuZWVkcyB0byBiZSBpbnNlcnRlZCB0byBub2RlXG59XG5cblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gLi9zcmMvZXVsZXIvcXVhZHRyZWUvaW5zZXJ0U3RhY2suanMiLCIvKipcbiAqIEludGVybmFsIGRhdGEgc3RydWN0dXJlIHRvIHJlcHJlc2VudCAyRCBRdWFkVHJlZSBub2RlXG4gKi9cbm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24gTm9kZSgpIHtcbiAgLy8gYm9keSBzdG9yZWQgaW5zaWRlIHRoaXMgbm9kZS4gSW4gcXVhZCB0cmVlIG9ubHkgbGVhZiBub2RlcyAoYnkgY29uc3RydWN0aW9uKVxuICAvLyBjb250YWluIGJvaWRlczpcbiAgdGhpcy5ib2R5ID0gbnVsbDtcblxuICAvLyBDaGlsZCBub2RlcyBhcmUgc3RvcmVkIGluIHF1YWRzLiBFYWNoIHF1YWQgaXMgcHJlc2VudGVkIGJ5IG51bWJlcjpcbiAgLy8gMCB8IDFcbiAgLy8gLS0tLS1cbiAgLy8gMiB8IDNcbiAgdGhpcy5xdWFkMCA9IG51bGw7XG4gIHRoaXMucXVhZDEgPSBudWxsO1xuICB0aGlzLnF1YWQyID0gbnVsbDtcbiAgdGhpcy5xdWFkMyA9IG51bGw7XG5cbiAgLy8gVG90YWwgbWFzcyBvZiBjdXJyZW50IG5vZGVcbiAgdGhpcy5tYXNzID0gMDtcblxuICAvLyBDZW50ZXIgb2YgbWFzcyBjb29yZGluYXRlc1xuICB0aGlzLm1hc3NYID0gMDtcbiAgdGhpcy5tYXNzWSA9IDA7XG5cbiAgLy8gYm91bmRpbmcgYm94IGNvb3JkaW5hdGVzXG4gIHRoaXMubGVmdCA9IDA7XG4gIHRoaXMudG9wID0gMDtcbiAgdGhpcy5ib3R0b20gPSAwO1xuICB0aGlzLnJpZ2h0ID0gMDtcbn07XG5cblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gLi9zcmMvZXVsZXIvcXVhZHRyZWUvbm9kZS5qcyIsImNvbnN0IHsgaW50ZWdyYXRlIH0gPSByZXF1aXJlKCcuL2ludGVncmF0ZScpO1xuY29uc3QgeyBhcHBseURyYWcgfSA9IHJlcXVpcmUoJy4vZHJhZycpO1xuY29uc3QgeyBhcHBseVNwcmluZyB9ID0gcmVxdWlyZSgnLi9zcHJpbmcnKTtcblxuZnVuY3Rpb24gdGljayh7IGJvZGllcywgc3ByaW5ncywgcXVhZHRyZWUsIHRpbWVTdGVwLCBncmF2aXR5LCB0aGV0YSwgZHJhZ0NvZWZmLCBwdWxsIH0pe1xuICAvLyB1cGRhdGUgYm9keSBmcm9tIHNjcmF0Y2ggaW4gY2FzZSBvZiBhbnkgY2hhbmdlc1xuICBib2RpZXMuZm9yRWFjaCggYm9keSA9PiB7XG4gICAgbGV0IHAgPSBib2R5Ll9zY3JhdGNoO1xuXG4gICAgaWYoICFwICl7IHJldHVybjsgfVxuXG4gICAgYm9keS5sb2NrZWQgPSBwLmxvY2tlZDtcbiAgICBib2R5LmdyYWJiZWQgPSBwLmdyYWJiZWQ7XG4gICAgYm9keS5wb3MueCA9IHAueDtcbiAgICBib2R5LnBvcy55ID0gcC55O1xuICB9ICk7XG5cbiAgcXVhZHRyZWUuaW5zZXJ0Qm9kaWVzKCBib2RpZXMgKTtcblxuICBmb3IoIGxldCBpID0gMDsgaSA8IGJvZGllcy5sZW5ndGg7IGkrKyApe1xuICAgIGxldCBib2R5ID0gYm9kaWVzW2ldO1xuXG4gICAgcXVhZHRyZWUudXBkYXRlQm9keUZvcmNlKCBib2R5LCBncmF2aXR5LCB0aGV0YSwgcHVsbCApO1xuICAgIGFwcGx5RHJhZyggYm9keSwgZHJhZ0NvZWZmICk7XG4gIH1cblxuICBmb3IoIGxldCBpID0gMDsgaSA8IHNwcmluZ3MubGVuZ3RoOyBpKysgKXtcbiAgICBsZXQgc3ByaW5nID0gc3ByaW5nc1tpXTtcblxuICAgIGFwcGx5U3ByaW5nKCBzcHJpbmcgKTtcbiAgfVxuXG4gIGxldCBtb3ZlbWVudCA9IGludGVncmF0ZSggYm9kaWVzLCB0aW1lU3RlcCApO1xuXG4gIC8vIHVwZGF0ZSBzY3JhdGNoIHBvc2l0aW9ucyBmcm9tIGJvZHkgcG9zaXRpb25zXG4gIGJvZGllcy5mb3JFYWNoKCBib2R5ID0+IHtcbiAgICBsZXQgcCA9IGJvZHkuX3NjcmF0Y2g7XG5cbiAgICBpZiggIXAgKXsgcmV0dXJuOyB9XG5cbiAgICBwLnggPSBib2R5LnBvcy54O1xuICAgIHAueSA9IGJvZHkucG9zLnk7XG4gIH0gKTtcblxuICByZXR1cm4gbW92ZW1lbnQ7XG59XG5cbm1vZHVsZS5leHBvcnRzID0geyB0aWNrIH07XG5cblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gLi9zcmMvZXVsZXIvdGljay5qcyIsImNvbnN0IEV1bGVyID0gcmVxdWlyZSgnLi9ldWxlcicpO1xuXG4vLyByZWdpc3RlcnMgdGhlIGV4dGVuc2lvbiBvbiBhIGN5dG9zY2FwZSBsaWIgcmVmXG5sZXQgcmVnaXN0ZXIgPSBmdW5jdGlvbiggY3l0b3NjYXBlICl7XG4gIGlmKCAhY3l0b3NjYXBlICl7IHJldHVybjsgfSAvLyBjYW4ndCByZWdpc3RlciBpZiBjeXRvc2NhcGUgdW5zcGVjaWZpZWRcblxuICBjeXRvc2NhcGUoICdsYXlvdXQnLCAnZXVsZXInLCBFdWxlciApOyAvLyByZWdpc3RlciB3aXRoIGN5dG9zY2FwZS5qc1xufTtcblxuaWYoIHR5cGVvZiBjeXRvc2NhcGUgIT09ICd1bmRlZmluZWQnICl7IC8vIGV4cG9zZSB0byBnbG9iYWwgY3l0b3NjYXBlIChpLmUuIHdpbmRvdy5jeXRvc2NhcGUpXG4gIHJlZ2lzdGVyKCBjeXRvc2NhcGUgKTtcbn1cblxubW9kdWxlLmV4cG9ydHMgPSByZWdpc3RlcjtcblxuXG5cbi8vIFdFQlBBQ0sgRk9PVEVSIC8vXG4vLyAuL3NyYy9pbmRleC5qcyIsIi8vIGdlbmVyYWwgZGVmYXVsdCBvcHRpb25zIGZvciBmb3JjZS1kaXJlY3RlZCBsYXlvdXRcblxubW9kdWxlLmV4cG9ydHMgPSBPYmplY3QuZnJlZXplKHtcbiAgYW5pbWF0ZTogdHJ1ZSwgLy8gd2hldGhlciB0byBzaG93IHRoZSBsYXlvdXQgYXMgaXQncyBydW5uaW5nOyBzcGVjaWFsICdlbmQnIHZhbHVlIG1ha2VzIHRoZSBsYXlvdXQgYW5pbWF0ZSBsaWtlIGEgZGlzY3JldGUgbGF5b3V0XG4gIHJlZnJlc2g6IDEwLCAvLyBudW1iZXIgb2YgdGlja3MgcGVyIGZyYW1lOyBoaWdoZXIgaXMgZmFzdGVyIGJ1dCBtb3JlIGplcmt5XG4gIG1heEl0ZXJhdGlvbnM6IDEwMDAsIC8vIG1heCBpdGVyYXRpb25zIGJlZm9yZSB0aGUgbGF5b3V0IHdpbGwgYmFpbCBvdXRcbiAgbWF4U2ltdWxhdGlvblRpbWU6IDQwMDAsIC8vIG1heCBsZW5ndGggaW4gbXMgdG8gcnVuIHRoZSBsYXlvdXRcbiAgdW5ncmFiaWZ5V2hpbGVTaW11bGF0aW5nOiBmYWxzZSwgLy8gc28geW91IGNhbid0IGRyYWcgbm9kZXMgZHVyaW5nIGxheW91dFxuICBmaXQ6IHRydWUsIC8vIG9uIGV2ZXJ5IGxheW91dCByZXBvc2l0aW9uIG9mIG5vZGVzLCBmaXQgdGhlIHZpZXdwb3J0XG4gIHBhZGRpbmc6IDMwLCAvLyBwYWRkaW5nIGFyb3VuZCB0aGUgc2ltdWxhdGlvblxuICBib3VuZGluZ0JveDogdW5kZWZpbmVkLCAvLyBjb25zdHJhaW4gbGF5b3V0IGJvdW5kczsgeyB4MSwgeTEsIHgyLCB5MiB9IG9yIHsgeDEsIHkxLCB3LCBoIH1cblxuICAvLyBsYXlvdXQgZXZlbnQgY2FsbGJhY2tzXG4gIHJlYWR5OiBmdW5jdGlvbigpe30sIC8vIG9uIGxheW91dHJlYWR5XG4gIHN0b3A6IGZ1bmN0aW9uKCl7fSwgLy8gb24gbGF5b3V0c3RvcFxuXG4gIC8vIHBvc2l0aW9uaW5nIG9wdGlvbnNcbiAgcmFuZG9taXplOiBmYWxzZSwgLy8gdXNlIHJhbmRvbSBub2RlIHBvc2l0aW9ucyBhdCBiZWdpbm5pbmcgb2YgbGF5b3V0XG4gIFxuICAvLyBpbmZpbml0ZSBsYXlvdXQgb3B0aW9uc1xuICBpbmZpbml0ZTogZmFsc2UgLy8gb3ZlcnJpZGVzIGFsbCBvdGhlciBvcHRpb25zIGZvciBhIGZvcmNlcy1hbGwtdGhlLXRpbWUgbW9kZVxufSk7XG5cblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gLi9zcmMvbGF5b3V0L2RlZmF1bHRzLmpzIiwiLyoqXG5BIGdlbmVyaWMgY29udGludW91cyBsYXlvdXQgY2xhc3NcbiovXG5cbmNvbnN0IGFzc2lnbiA9IHJlcXVpcmUoJy4uL2Fzc2lnbicpO1xuY29uc3QgZGVmYXVsdHMgPSByZXF1aXJlKCcuL2RlZmF1bHRzJyk7XG5jb25zdCBtYWtlQm91bmRpbmdCb3ggPSByZXF1aXJlKCcuL21ha2UtYmInKTtcbmNvbnN0IHsgc2V0SW5pdGlhbFBvc2l0aW9uU3RhdGUsIHJlZnJlc2hQb3NpdGlvbnMsIGdldE5vZGVQb3NpdGlvbkRhdGEgfSA9IHJlcXVpcmUoJy4vcG9zaXRpb24nKTtcbmNvbnN0IHsgbXVsdGl0aWNrIH0gPSByZXF1aXJlKCcuL3RpY2snKTtcblxuY2xhc3MgTGF5b3V0IHtcbiAgY29uc3RydWN0b3IoIG9wdGlvbnMgKXtcbiAgICBsZXQgbyA9IHRoaXMub3B0aW9ucyA9IGFzc2lnbigge30sIGRlZmF1bHRzLCBvcHRpb25zICk7XG5cblx0XHRsZXQgbm9kZXMgPSBvLmVsZXMubm9kZXMoKTtcblx0XHQvLyBwcmV2ZW50IGluZmluaXRlIGxvb3AgYW5kIG1lbW9yeSBvdmVyZmxvdyB3aGVuIG5vZGVzIG9jY3VweSB0aGUgc2FtZSBwb3NpdGlvblxuXHRcdGlmKCFvLnJhbmRvbWl6ZSlcblx0XHR7XG5cdFx0XHRub2RlcyA9IG5vZGVzLnNvcnQoKGEsYik9PmEucG9zaXRpb24oKS54LWIucG9zaXRpb24oKS54KTtcblx0XHRcdGNvbnN0IHByZXYgPSB7eDogMCwgeTogMH07XG5cdFx0XHRjb25zdCBwb3MgPSB7fTtcblx0XHRcdG5vZGVzLmZvckVhY2gobj0+XG5cdFx0XHR7XG5cdFx0XHRcdE9iamVjdC5hc3NpZ24ocG9zLG4ucG9zaXRpb24oKSk7XG5cdFx0XHRcdGlmKE1hdGguYWJzKHByZXYueCAtIHBvcy54KSA8IG8udGhldGEgJiYgTWF0aC5hYnMocHJldi55IC0gcG9zLnkpIDwgby50aGV0YSlcblx0XHRcdFx0e1xuXHRcdFx0XHRcdG4ucG9zaXRpb24oe3g6IE1hdGgucmFuZG9tKCkqMTAwLCB5OiBNYXRoLnJhbmRvbSgpKjEwMH0pO1xuXHRcdFx0XHR9XG5cdFx0XHRcdE9iamVjdC5hc3NpZ24ocHJldixwb3MpO1xuXHRcdFx0fSk7XG5cdFx0fVxuXG4gICAgbGV0IHMgPSB0aGlzLnN0YXRlID0gYXNzaWduKCB7fSwgbywge1xuICAgICAgbGF5b3V0OiB0aGlzLFxuICAgICAgbm9kZXMsXG4gICAgICBlZGdlczogby5lbGVzLmVkZ2VzKCksXG4gICAgICB0aWNrSW5kZXg6IDAsXG4gICAgICBmaXJzdFVwZGF0ZTogdHJ1ZVxuICAgIH0gKTtcblxuICAgIHMuYW5pbWF0ZUVuZCA9IG8uYW5pbWF0ZSAmJiBvLmFuaW1hdGUgPT09ICdlbmQnO1xuICAgIHMuYW5pbWF0ZUNvbnRpbnVvdXNseSA9IG8uYW5pbWF0ZSAmJiAhcy5hbmltYXRlRW5kO1xuICB9XG5cbiAgcnVuKCl7XG4gICAgbGV0IGwgPSB0aGlzO1xuICAgIGxldCBzID0gdGhpcy5zdGF0ZTtcblxuICAgIHMudGlja0luZGV4ID0gMDtcbiAgICBzLmZpcnN0VXBkYXRlID0gdHJ1ZTtcbiAgICBzLnN0YXJ0VGltZSA9IERhdGUubm93KCk7XG4gICAgcy5ydW5uaW5nID0gdHJ1ZTtcblxuICAgIHMuY3VycmVudEJvdW5kaW5nQm94ID0gbWFrZUJvdW5kaW5nQm94KCBzLmJvdW5kaW5nQm94LCBzLmN5ICk7XG5cbiAgICBpZiggcy5yZWFkeSApeyBsLm9uZSggJ3JlYWR5Jywgcy5yZWFkeSApOyB9XG4gICAgaWYoIHMuc3RvcCApeyBsLm9uZSggJ3N0b3AnLCBzLnN0b3AgKTsgfVxuXG4gICAgcy5ub2Rlcy5mb3JFYWNoKCBuID0+IHNldEluaXRpYWxQb3NpdGlvblN0YXRlKCBuLCBzICkgKTtcblxuICAgIGwucHJlcnVuKCBzICk7XG5cbiAgICBpZiggcy5hbmltYXRlQ29udGludW91c2x5ICl7XG4gICAgICBsZXQgdW5ncmFiaWZ5ID0gbm9kZSA9PiB7XG4gICAgICAgIGlmKCAhcy51bmdyYWJpZnlXaGlsZVNpbXVsYXRpbmcgKXsgcmV0dXJuOyB9XG5cbiAgICAgICAgbGV0IGdyYWJiYWJsZSA9IGdldE5vZGVQb3NpdGlvbkRhdGEoIG5vZGUsIHMgKS5ncmFiYmFibGUgPSBub2RlLmdyYWJiYWJsZSgpO1xuXG4gICAgICAgIGlmKCBncmFiYmFibGUgKXtcbiAgICAgICAgICBub2RlLnVuZ3JhYmlmeSgpO1xuICAgICAgICB9XG4gICAgICB9O1xuXG4gICAgICBsZXQgcmVncmFiaWZ5ID0gbm9kZSA9PiB7XG4gICAgICAgIGlmKCAhcy51bmdyYWJpZnlXaGlsZVNpbXVsYXRpbmcgKXsgcmV0dXJuOyB9XG5cbiAgICAgICAgbGV0IGdyYWJiYWJsZSA9IGdldE5vZGVQb3NpdGlvbkRhdGEoIG5vZGUsIHMgKS5ncmFiYmFibGU7XG5cbiAgICAgICAgaWYoIGdyYWJiYWJsZSApe1xuICAgICAgICAgIG5vZGUuZ3JhYmlmeSgpO1xuICAgICAgICB9XG4gICAgICB9O1xuXG4gICAgICBsZXQgdXBkYXRlR3JhYlN0YXRlID0gbm9kZSA9PiBnZXROb2RlUG9zaXRpb25EYXRhKCBub2RlLCBzICkuZ3JhYmJlZCA9IG5vZGUuZ3JhYmJlZCgpO1xuXG4gICAgICBsZXQgb25HcmFiID0gZnVuY3Rpb24oeyB0YXJnZXQgfSl7XG4gICAgICAgIHVwZGF0ZUdyYWJTdGF0ZSggdGFyZ2V0ICk7XG4gICAgICB9O1xuXG4gICAgICBsZXQgb25GcmVlID0gb25HcmFiO1xuXG4gICAgICBsZXQgb25EcmFnID0gZnVuY3Rpb24oeyB0YXJnZXQgfSl7XG4gICAgICAgIGxldCBwID0gZ2V0Tm9kZVBvc2l0aW9uRGF0YSggdGFyZ2V0LCBzICk7XG4gICAgICAgIGxldCB0cCA9IHRhcmdldC5wb3NpdGlvbigpO1xuXG4gICAgICAgIHAueCA9IHRwLng7XG4gICAgICAgIHAueSA9IHRwLnk7XG4gICAgICB9O1xuXG4gICAgICBsZXQgbGlzdGVuVG9HcmFiID0gbm9kZSA9PiB7XG4gICAgICAgIG5vZGUub24oJ2dyYWInLCBvbkdyYWIpO1xuICAgICAgICBub2RlLm9uKCdmcmVlJywgb25GcmVlKTtcbiAgICAgICAgbm9kZS5vbignZHJhZycsIG9uRHJhZyk7XG4gICAgICB9O1xuXG4gICAgICBsZXQgdW5saXN0ZW5Ub0dyYWIgPSBub2RlID0+IHtcbiAgICAgICAgbm9kZS5yZW1vdmVMaXN0ZW5lcignZ3JhYicsIG9uR3JhYik7XG4gICAgICAgIG5vZGUucmVtb3ZlTGlzdGVuZXIoJ2ZyZWUnLCBvbkZyZWUpO1xuICAgICAgICBub2RlLnJlbW92ZUxpc3RlbmVyKCdkcmFnJywgb25EcmFnKTtcbiAgICAgIH07XG5cbiAgICAgIGxldCBmaXQgPSAoKSA9PiB7XG4gICAgICAgIGlmKCBzLmZpdCAmJiBzLmFuaW1hdGVDb250aW51b3VzbHkgKXtcbiAgICAgICAgICBzLmN5LmZpdCggcy5wYWRkaW5nICk7XG4gICAgICAgIH1cbiAgICAgIH07XG5cbiAgICAgIGxldCBvbk5vdERvbmUgPSAoKSA9PiB7XG4gICAgICAgIHJlZnJlc2hQb3NpdGlvbnMoIHMubm9kZXMsIHMgKTtcbiAgICAgICAgZml0KCk7XG5cbiAgICAgICAgcmVxdWVzdEFuaW1hdGlvbkZyYW1lKCBmcmFtZSApO1xuICAgICAgfTtcblxuICAgICAgbGV0IGZyYW1lID0gZnVuY3Rpb24oKXtcbiAgICAgICAgbXVsdGl0aWNrKCBzLCBvbk5vdERvbmUsIG9uRG9uZSApO1xuICAgICAgfTtcblxuICAgICAgbGV0IG9uRG9uZSA9ICgpID0+IHtcbiAgICAgICAgcmVmcmVzaFBvc2l0aW9ucyggcy5ub2RlcywgcyApO1xuICAgICAgICBmaXQoKTtcblxuICAgICAgICBzLm5vZGVzLmZvckVhY2goIG4gPT4ge1xuICAgICAgICAgIHJlZ3JhYmlmeSggbiApO1xuICAgICAgICAgIHVubGlzdGVuVG9HcmFiKCBuICk7XG4gICAgICAgIH0gKTtcblxuICAgICAgICBzLnJ1bm5pbmcgPSBmYWxzZTtcblxuICAgICAgICBsLmVtaXQoJ2xheW91dHN0b3AnKTtcbiAgICAgIH07XG5cbiAgICAgIGwuZW1pdCgnbGF5b3V0c3RhcnQnKTtcblxuICAgICAgcy5ub2Rlcy5mb3JFYWNoKCBuID0+IHtcbiAgICAgICAgdW5ncmFiaWZ5KCBuICk7XG4gICAgICAgIGxpc3RlblRvR3JhYiggbiApO1xuICAgICAgfSApO1xuXG4gICAgICBmcmFtZSgpOyAvLyBraWNrIG9mZlxuICAgIH0gZWxzZSB7XG4gICAgICBsZXQgZG9uZSA9IGZhbHNlO1xuICAgICAgbGV0IG9uTm90RG9uZSA9ICgpID0+IHt9O1xuICAgICAgbGV0IG9uRG9uZSA9ICgpID0+IGRvbmUgPSB0cnVlO1xuXG4gICAgICB3aGlsZSggIWRvbmUgKXtcbiAgICAgICAgbXVsdGl0aWNrKCBzLCBvbk5vdERvbmUsIG9uRG9uZSApO1xuICAgICAgfVxuXG4gICAgICBzLmVsZXMubGF5b3V0UG9zaXRpb25zKCB0aGlzLCBzLCBub2RlID0+IHtcbiAgICAgICAgbGV0IHBkID0gZ2V0Tm9kZVBvc2l0aW9uRGF0YSggbm9kZSwgcyApO1xuXG4gICAgICAgIHJldHVybiB7IHg6IHBkLngsIHk6IHBkLnkgfTtcbiAgICAgIH0gKTtcbiAgICB9XG5cbiAgICBsLnBvc3RydW4oIHMgKTtcblxuICAgIHJldHVybiB0aGlzOyAvLyBjaGFpbmluZ1xuICB9XG5cbiAgcHJlcnVuKCl7fVxuICBwb3N0cnVuKCl7fVxuICB0aWNrKCl7fVxuXG4gIHN0b3AoKXtcbiAgICB0aGlzLnN0YXRlLnJ1bm5pbmcgPSBmYWxzZTtcblxuICAgIHJldHVybiB0aGlzOyAvLyBjaGFpbmluZ1xuICB9XG5cbiAgZGVzdHJveSgpe1xuICAgIHJldHVybiB0aGlzOyAvLyBjaGFpbmluZ1xuICB9XG59XG5cbm1vZHVsZS5leHBvcnRzID0gTGF5b3V0O1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2xheW91dC9pbmRleC5qcyIsIm1vZHVsZS5leHBvcnRzID0gZnVuY3Rpb24oIGJiLCBjeSApe1xuICBpZiggYmIgPT0gbnVsbCApe1xuICAgIGJiID0geyB4MTogMCwgeTE6IDAsIHc6IGN5LndpZHRoKCksIGg6IGN5LmhlaWdodCgpIH07XG4gIH0gZWxzZSB7IC8vIGNvcHlcbiAgICBiYiA9IHsgeDE6IGJiLngxLCB4MjogYmIueDIsIHkxOiBiYi55MSwgeTI6IGJiLnkyLCB3OiBiYi53LCBoOiBiYi5oIH07XG4gIH1cblxuICBpZiggYmIueDIgPT0gbnVsbCApeyBiYi54MiA9IGJiLngxICsgYmIudzsgfVxuICBpZiggYmIudyA9PSBudWxsICl7IGJiLncgPSBiYi54MiAtIGJiLngxOyB9XG4gIGlmKCBiYi55MiA9PSBudWxsICl7IGJiLnkyID0gYmIueTEgKyBiYi5oOyB9XG4gIGlmKCBiYi5oID09IG51bGwgKXsgYmIuaCA9IGJiLnkyIC0gYmIueTE7IH1cblxuICByZXR1cm4gYmI7XG59O1xuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2xheW91dC9tYWtlLWJiLmpzIiwiY29uc3QgYXNzaWduID0gcmVxdWlyZSgnLi4vYXNzaWduJyk7XG5cbmxldCBzZXRJbml0aWFsUG9zaXRpb25TdGF0ZSA9IGZ1bmN0aW9uKCBub2RlLCBzdGF0ZSApe1xuICBsZXQgcCA9IG5vZGUucG9zaXRpb24oKTtcbiAgbGV0IGJiID0gc3RhdGUuY3VycmVudEJvdW5kaW5nQm94O1xuICBsZXQgc2NyYXRjaCA9IG5vZGUuc2NyYXRjaCggc3RhdGUubmFtZSApO1xuXG4gIGlmKCBzY3JhdGNoID09IG51bGwgKXtcbiAgICBzY3JhdGNoID0ge307XG5cbiAgICBub2RlLnNjcmF0Y2goIHN0YXRlLm5hbWUsIHNjcmF0Y2ggKTtcbiAgfVxuXG4gIGFzc2lnbiggc2NyYXRjaCwgc3RhdGUucmFuZG9taXplID8ge1xuICAgIHg6IGJiLngxICsgTWF0aC5yYW5kb20oKSAqIGJiLncsXG4gICAgeTogYmIueTEgKyBNYXRoLnJhbmRvbSgpICogYmIuaFxuICB9IDoge1xuICAgIHg6IHAueCxcbiAgICB5OiBwLnlcbiAgfSApO1xuXG4gIHNjcmF0Y2gubG9ja2VkID0gbm9kZS5sb2NrZWQoKTtcbn07XG5cbmxldCBnZXROb2RlUG9zaXRpb25EYXRhID0gZnVuY3Rpb24oIG5vZGUsIHN0YXRlICl7XG4gIHJldHVybiBub2RlLnNjcmF0Y2goIHN0YXRlLm5hbWUgKTtcbn07XG5cbmxldCByZWZyZXNoUG9zaXRpb25zID0gZnVuY3Rpb24oIG5vZGVzLCBzdGF0ZSApe1xuICBub2Rlcy5wb3NpdGlvbnMoZnVuY3Rpb24oIG5vZGUgKXtcbiAgICBsZXQgc2NyYXRjaCA9IG5vZGUuc2NyYXRjaCggc3RhdGUubmFtZSApO1xuXG4gICAgcmV0dXJuIHtcbiAgICAgIHg6IHNjcmF0Y2gueCxcbiAgICAgIHk6IHNjcmF0Y2gueVxuICAgIH07XG4gIH0pO1xufTtcblxubW9kdWxlLmV4cG9ydHMgPSB7IHNldEluaXRpYWxQb3NpdGlvblN0YXRlLCBnZXROb2RlUG9zaXRpb25EYXRhLCByZWZyZXNoUG9zaXRpb25zIH07XG5cblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gLi9zcmMvbGF5b3V0L3Bvc2l0aW9uLmpzIiwiY29uc3Qgbm9wID0gZnVuY3Rpb24oKXt9O1xuXG5sZXQgdGljayA9IGZ1bmN0aW9uKCBzdGF0ZSApe1xuICBsZXQgcyA9IHN0YXRlO1xuICBsZXQgbCA9IHN0YXRlLmxheW91dDtcblxuICBsZXQgdGlja0luZGljYXRlc0RvbmUgPSBsLnRpY2soIHMgKTtcblxuICBpZiggcy5maXJzdFVwZGF0ZSApe1xuICAgIGlmKCBzLmFuaW1hdGVDb250aW51b3VzbHkgKXsgLy8gaW5kaWNhdGUgdGhlIGluaXRpYWwgcG9zaXRpb25zIGhhdmUgYmVlbiBzZXRcbiAgICAgIHMubGF5b3V0LmVtaXQoJ2xheW91dHJlYWR5Jyk7XG4gICAgfVxuICAgIHMuZmlyc3RVcGRhdGUgPSBmYWxzZTtcbiAgfVxuXG4gIHMudGlja0luZGV4Kys7XG5cbiAgbGV0IGR1cmF0aW9uID0gRGF0ZS5ub3coKSAtIHMuc3RhcnRUaW1lO1xuXG4gIHJldHVybiAhcy5pbmZpbml0ZSAmJiAoIHRpY2tJbmRpY2F0ZXNEb25lIHx8IHMudGlja0luZGV4ID49IHMubWF4SXRlcmF0aW9ucyB8fCBkdXJhdGlvbiA+PSBzLm1heFNpbXVsYXRpb25UaW1lICk7XG59O1xuXG5sZXQgbXVsdGl0aWNrID0gZnVuY3Rpb24oIHN0YXRlLCBvbk5vdERvbmUgPSBub3AsIG9uRG9uZSA9IG5vcCApe1xuICBsZXQgZG9uZSA9IGZhbHNlO1xuICBsZXQgcyA9IHN0YXRlO1xuXG4gIGZvciggbGV0IGkgPSAwOyBpIDwgcy5yZWZyZXNoOyBpKysgKXtcbiAgICBkb25lID0gIXMucnVubmluZyB8fCB0aWNrKCBzICk7XG5cbiAgICBpZiggZG9uZSApeyBicmVhazsgfVxuICB9XG5cbiAgaWYoICFkb25lICl7XG4gICAgb25Ob3REb25lKCk7XG4gIH0gZWxzZSB7XG4gICAgb25Eb25lKCk7XG4gIH1cbn07XG5cbm1vZHVsZS5leHBvcnRzID0geyB0aWNrLCBtdWx0aXRpY2sgfTtcblxuXG5cbi8vIFdFQlBBQ0sgRk9PVEVSIC8vXG4vLyAuL3NyYy9sYXlvdXQvdGljay5qcyJdLCJzb3VyY2VSb290IjoiIn0=