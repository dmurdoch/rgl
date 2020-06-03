
    /**
     * Multiply matrix by vector
     * @returns {number[]}
     * @param M {number[][]} Left operand
     * @param v {number[]} Right operand
     */
    rglwidgetClass.prototype.multMV = function(M, v) {
        return [ M.m11 * v[0] + M.m12 * v[1] + M.m13 * v[2] + M.m14 * v[3],
                 M.m21 * v[0] + M.m22 * v[1] + M.m23 * v[2] + M.m24 * v[3],
                 M.m31 * v[0] + M.m32 * v[1] + M.m33 * v[2] + M.m34 * v[3],
                 M.m41 * v[0] + M.m42 * v[1] + M.m43 * v[2] + M.m44 * v[3]
               ];
    };
    
    /**
     * Multiply row vector by Matrix
     * @returns {number[]}
     * @param v {number[]} left operand
     * @param M {number[][]} right operand
     */
    rglwidgetClass.prototype.multVM = function(v, M) {
        return [ M.m11 * v[0] + M.m21 * v[1] + M.m31 * v[2] + M.m41 * v[3],
                 M.m12 * v[0] + M.m22 * v[1] + M.m32 * v[2] + M.m42 * v[3],
                 M.m13 * v[0] + M.m23 * v[1] + M.m33 * v[2] + M.m43 * v[3],
                 M.m14 * v[0] + M.m24 * v[1] + M.m34 * v[2] + M.m44 * v[3]
               ];
    };
    
    /**
     * Euclidean length of a vector
     * @returns {number}
     * @param v {number[]}
     */
    rglwidgetClass.prototype.vlen = function(v) {
      return Math.sqrt(this.dotprod(v, v));
    };

    /**
     * Dot product of two vectors
     * @instance rglwidgetClass
     * @returns {number}
     * @param a {number[]}
     * @param b {number[]}
     */
    rglwidgetClass.prototype.dotprod = function(a, b) {
      return a[0]*b[0] + a[1]*b[1] + a[2]*b[2];
    };

    /**
     * Cross product of two vectors
     * @returns {number[]}
     * @param a {number[]}
     * @param b {number[]}
     */
    rglwidgetClass.prototype.xprod = function(a, b) {
      return [a[1]*b[2] - a[2]*b[1],
          a[2]*b[0] - a[0]*b[2],
          a[0]*b[1] - a[1]*b[0]];
    };

    /**
     * Bind vectors or matrices by columns
     * @returns {number[][]}
     * @param a {number[]|number[][]}
     * @param b {number[]|number[][]}
     */
    rglwidgetClass.prototype.cbind = function(a, b) {
      if (b.length < a.length)
        b = this.repeatToLen(b, a.length);
      else if (a.length < b.length)
        a = this.repeatToLen(a, b.length);
      return a.map(function(currentValue, index) {
            return currentValue.concat(b[index]);
      });
    };

    /**
     * Swap elements
     * @returns {any[]}
     * @param a {any[]}
     * @param i {number} Element to swap
     * @param j {number} Other element to swap
     */
    rglwidgetClass.prototype.swap = function(a, i, j) {
      var temp = a[i];
      a[i] = a[j];
      a[j] = temp;
    };

    /**
     * Flatten a matrix into a vector
     * @returns {any[]}
     * @param a {any[][]}
     */
    rglwidgetClass.prototype.flatten = function(arr, result) {
      var value;
      if (typeof result === "undefined") result = [];
      for (var i = 0, length = arr.length; i < length; i++) {
        value = arr[i];
        if (Array.isArray(value)) {
          this.flatten(value, result);
        } else {
          result.push(value);
        }
      }
      return result;
    };

    /**
     * set element of 1d or 2d array as if it was flattened.
     * Column major, zero based!
     * @returns {any[]|any[][]}
     * @param {any[]|any[][]} a - array
     * @param {number} i - element
     * @param {any} value
     */
    rglwidgetClass.prototype.setElement = function(a, i, value) {
      if (Array.isArray(a[0])) {
        var dim = a.length,
            col = Math.floor(i/dim),
            row = i % dim;
        a[row][col] = value;
      } else {
        a[i] = value;
      }
    };

    /**
     * Transpose an array
     * @returns {any[][]}
     * @param {any[][]} a
     */
    rglwidgetClass.prototype.transpose = function(a) {
      var newArray = [],
          n = a.length,
          m = a[0].length,
          i;
      for(i = 0; i < m; i++){
        newArray.push([]);
      }

      for(i = 0; i < n; i++){
        for(var j = 0; j < m; j++){
          newArray[j].push(a[i][j]);
        }
      }
      return newArray;
    };

    /**
     * Calculate sum of squares of a numeric vector
     * @returns {number}
     * @param {number[]} x
     */
    rglwidgetClass.prototype.sumsq = function(x) {
      var result = 0, i;
      for (i=0; i < x.length; i++)
        result += x[i]*x[i];
      return result;
    };

    /**
     * Convert a matrix to a CanvasMatrix4
     * @returns {CanvasMatrix4}
     * @param {number[][]|number[]} mat
     */
    rglwidgetClass.prototype.toCanvasMatrix4 = function(mat) {
      if (mat instanceof CanvasMatrix4)
        return mat;
      var result = new CanvasMatrix4();
      mat = this.flatten(this.transpose(mat));
      result.load(mat);
      return result;
    };

    /**
     * Convert an R-style numeric colour string to an rgb vector
     * @returns {number[]}
     * @param {string} s
     */
    rglwidgetClass.prototype.stringToRgb = function(s) {
      s = s.replace("#", "");
      var bigint = parseInt(s, 16);
      return [((bigint >> 16) & 255)/255,
              ((bigint >> 8) & 255)/255,
               (bigint & 255)/255];
    };

    /**
     * Take a component-by-component product of two 3 vectors
     * @returns {number[]}
     * @param {number[]} x
     * @param {number[]} y
     */
    rglwidgetClass.prototype.componentProduct = function(x, y) {
      if (typeof y === "undefined") {
        this.alertOnce("Bad arg to componentProduct");
      }
      var result = new Float32Array(3), i;
      for (i = 0; i<3; i++)
        result[i] = x[i]*y[i];
      return result;
    };

    /**
     * Get next higher power of two
     * @returns { number }
     * @param { number } value - input value
     */
    rglwidgetClass.prototype.getPowerOfTwo = function(value) {
      var pow = 1;
      while(pow<value) {
        pow *= 2;
      }
      return pow;
    };

    /**
     * Unique entries
     * @returns { any[] }
     * @param { any[] } arr - An array
     */
    rglwidgetClass.prototype.unique = function(arr) {
      arr = [].concat(arr);
      return arr.filter(function(value, index, self) {
        return self.indexOf(value) === index;
      });
    };

    /**
     * Shallow compare of arrays
     * @returns { boolean }
     * @param { any[] } a - An array
     * @param { any[] } b - Another array
     */
    rglwidgetClass.prototype.equalArrays = function(a, b) {
      return a === b || (a && b &&
                      a.length === b.length &&
                      a.every(function(v, i) {return v === b[i];}));
    };
    
    /**
     * Repeat an array to a desired length
     * @returns {any[]}
     * @param {any | any[]} arr The input array
     * @param {number} len The desired output length
     */
    rglwidgetClass.prototype.repeatToLen = function(arr, len) {
      arr = [].concat(arr);
      while (arr.length < len/2)
        arr = arr.concat(arr);
      return arr.concat(arr.slice(0, len - arr.length));
    };

    /**
     * Give a single alert message, not to be repeated.
     * @param {string} msg  The message to give.
     */
    rglwidgetClass.prototype.alertOnce = function(msg) {
      if (typeof this.alerted !== "undefined")
        return;
      this.alerted = true;
      alert(msg);
    };
