(function(){const u=document.createElement("link").relList;if(u&&u.supports&&u.supports("modulepreload"))return;for(const p of document.querySelectorAll('link[rel="modulepreload"]'))a(p);new MutationObserver(p=>{for(const g of p)if(g.type==="childList")for(const h of g.addedNodes)h.tagName==="LINK"&&h.rel==="modulepreload"&&a(h)}).observe(document,{childList:!0,subtree:!0});function c(p){const g={};return p.integrity&&(g.integrity=p.integrity),p.referrerPolicy&&(g.referrerPolicy=p.referrerPolicy),p.crossOrigin==="use-credentials"?g.credentials="include":p.crossOrigin==="anonymous"?g.credentials="omit":g.credentials="same-origin",g}function a(p){if(p.ep)return;p.ep=!0;const g=c(p);fetch(p.href,g)}})();var mt={},J={};J.byteLength=Yt,J.toByteArray=Xt,J.fromByteArray=Qt;for(var _=[],L=[],Jt=typeof Uint8Array<"u"?Uint8Array:Array,tt="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",z=0,Wt=tt.length;z<Wt;++z)_[z]=tt[z],L[tt.charCodeAt(z)]=z;L[45]=62,L[95]=63;function bt(u){var c=u.length;if(c%4>0)throw new Error("Invalid string. Length must be a multiple of 4");var a=u.indexOf("=");a===-1&&(a=c);var p=a===c?0:4-a%4;return[a,p]}function Yt(u){var c=bt(u),a=c[0],p=c[1];return(a+p)*3/4-p}function Kt(u,c,a){return(c+a)*3/4-a}function Xt(u){var c,a=bt(u),p=a[0],g=a[1],h=new Jt(Kt(u,p,g)),l=0,E=g>0?p-4:p,d;for(d=0;d<E;d+=4)c=L[u.charCodeAt(d)]<<18|L[u.charCodeAt(d+1)]<<12|L[u.charCodeAt(d+2)]<<6|L[u.charCodeAt(d+3)],h[l++]=c>>16&255,h[l++]=c>>8&255,h[l++]=c&255;return g===2&&(c=L[u.charCodeAt(d)]<<2|L[u.charCodeAt(d+1)]>>4,h[l++]=c&255),g===1&&(c=L[u.charCodeAt(d)]<<10|L[u.charCodeAt(d+1)]<<4|L[u.charCodeAt(d+2)]>>2,h[l++]=c>>8&255,h[l++]=c&255),h}function Zt(u){return _[u>>18&63]+_[u>>12&63]+_[u>>6&63]+_[u&63]}function Ht(u,c,a){for(var p,g=[],h=c;h<a;h+=3)p=(u[h]<<16&16711680)+(u[h+1]<<8&65280)+(u[h+2]&255),g.push(Zt(p));return g.join("")}function Qt(u){for(var c,a=u.length,p=a%3,g=[],h=16383,l=0,E=a-p;l<E;l+=h)g.push(Ht(u,l,l+h>E?E:l+h));return p===1?(c=u[a-1],g.push(_[c>>2]+_[c<<4&63]+"==")):p===2&&(c=(u[a-2]<<8)+u[a-1],g.push(_[c>>10]+_[c>>4&63]+_[c<<2&63]+"=")),g.join("")}var et={};/*! ieee754. BSD-3-Clause License. Feross Aboukhadijeh <https://feross.org/opensource> */et.read=function(u,c,a,p,g){var h,l,E=g*8-p-1,d=(1<<E)-1,I=d>>1,i=-7,A=a?g-1:0,C=a?-1:1,U=u[c+A];for(A+=C,h=U&(1<<-i)-1,U>>=-i,i+=E;i>0;h=h*256+u[c+A],A+=C,i-=8);for(l=h&(1<<-i)-1,h>>=-i,i+=p;i>0;l=l*256+u[c+A],A+=C,i-=8);if(h===0)h=1-I;else{if(h===d)return l?NaN:(U?-1:1)*(1/0);l=l+Math.pow(2,p),h=h-I}return(U?-1:1)*l*Math.pow(2,h-p)},et.write=function(u,c,a,p,g,h){var l,E,d,I=h*8-g-1,i=(1<<I)-1,A=i>>1,C=g===23?Math.pow(2,-24)-Math.pow(2,-77):0,U=p?0:h-1,$=p?1:-1,Y=c<0||c===0&&1/c<0?1:0;for(c=Math.abs(c),isNaN(c)||c===1/0?(E=isNaN(c)?1:0,l=i):(l=Math.floor(Math.log(c)/Math.LN2),c*(d=Math.pow(2,-l))<1&&(l--,d*=2),l+A>=1?c+=C/d:c+=C*Math.pow(2,1-A),c*d>=2&&(l++,d/=2),l+A>=i?(E=0,l=i):l+A>=1?(E=(c*d-1)*Math.pow(2,g),l=l+A):(E=c*Math.pow(2,A-1)*Math.pow(2,g),l=0));g>=8;u[a+U]=E&255,U+=$,E/=256,g-=8);for(l=l<<g|E,I+=g;I>0;u[a+U]=l&255,U+=$,l/=256,I-=8);u[a+U-$]|=Y*128};/*!
* The buffer module from node.js, for the browser.
*
* @author   Feross Aboukhadijeh <https://feross.org>
* @license  MIT
*/(function(u){const c=J,a=et,p=typeof Symbol=="function"&&typeof Symbol.for=="function"?Symbol.for("nodejs.util.inspect.custom"):null;u.Buffer=i,u.SlowBuffer=Rt,u.INSPECT_MAX_BYTES=50;const g=2147483647;u.kMaxLength=g;const{Uint8Array:h,ArrayBuffer:l,SharedArrayBuffer:E}=globalThis;i.TYPED_ARRAY_SUPPORT=d(),!i.TYPED_ARRAY_SUPPORT&&typeof console<"u"&&typeof console.error=="function"&&console.error("This browser lacks typed array (Uint8Array) support which is required by `buffer` v5.x. Use `buffer` v4.x if you require old browser support.");function d(){try{const t=new h(1),e={foo:function(){return 42}};return Object.setPrototypeOf(e,h.prototype),Object.setPrototypeOf(t,e),t.foo()===42}catch{return!1}}Object.defineProperty(i.prototype,"parent",{enumerable:!0,get:function(){if(i.isBuffer(this))return this.buffer}}),Object.defineProperty(i.prototype,"offset",{enumerable:!0,get:function(){if(i.isBuffer(this))return this.byteOffset}});function I(t){if(t>g)throw new RangeError('The value "'+t+'" is invalid for option "size"');const e=new h(t);return Object.setPrototypeOf(e,i.prototype),e}function i(t,e,n){if(typeof t=="number"){if(typeof e=="string")throw new TypeError('The "string" argument must be of type string. Received type number');return $(t)}return A(t,e,n)}i.poolSize=8192;function A(t,e,n){if(typeof t=="string")return Y(t,e);if(l.isView(t))return Tt(t);if(t==null)throw new TypeError("The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type "+typeof t);if(O(t,l)||t&&O(t.buffer,l)||typeof E<"u"&&(O(t,E)||t&&O(t.buffer,E)))return rt(t,e,n);if(typeof t=="number")throw new TypeError('The "value" argument must not be of type number. Received type number');const o=t.valueOf&&t.valueOf();if(o!=null&&o!==t)return i.from(o,e,n);const r=At(t);if(r)return r;if(typeof Symbol<"u"&&Symbol.toPrimitive!=null&&typeof t[Symbol.toPrimitive]=="function")return i.from(t[Symbol.toPrimitive]("string"),e,n);throw new TypeError("The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type "+typeof t)}i.from=function(t,e,n){return A(t,e,n)},Object.setPrototypeOf(i.prototype,h.prototype),Object.setPrototypeOf(i,h);function C(t){if(typeof t!="number")throw new TypeError('"size" argument must be of type number');if(t<0)throw new RangeError('The value "'+t+'" is invalid for option "size"')}function U(t,e,n){return C(t),t<=0?I(t):e!==void 0?typeof n=="string"?I(t).fill(e,n):I(t).fill(e):I(t)}i.alloc=function(t,e,n){return U(t,e,n)};function $(t){return C(t),I(t<0?0:X(t)|0)}i.allocUnsafe=function(t){return $(t)},i.allocUnsafeSlow=function(t){return $(t)};function Y(t,e){if((typeof e!="string"||e==="")&&(e="utf8"),!i.isEncoding(e))throw new TypeError("Unknown encoding: "+e);const n=it(t,e)|0;let o=I(n);const r=o.write(t,e);return r!==n&&(o=o.slice(0,r)),o}function K(t){const e=t.length<0?0:X(t.length)|0,n=I(e);for(let o=0;o<e;o+=1)n[o]=t[o]&255;return n}function Tt(t){if(O(t,h)){const e=new h(t);return rt(e.buffer,e.byteOffset,e.byteLength)}return K(t)}function rt(t,e,n){if(e<0||t.byteLength<e)throw new RangeError('"offset" is outside of buffer bounds');if(t.byteLength<e+(n||0))throw new RangeError('"length" is outside of buffer bounds');let o;return e===void 0&&n===void 0?o=new h(t):n===void 0?o=new h(t,e):o=new h(t,e,n),Object.setPrototypeOf(o,i.prototype),o}function At(t){if(i.isBuffer(t)){const e=X(t.length)|0,n=I(e);return n.length===0||t.copy(n,0,0,e),n}if(t.length!==void 0)return typeof t.length!="number"||Q(t.length)?I(0):K(t);if(t.type==="Buffer"&&Array.isArray(t.data))return K(t.data)}function X(t){if(t>=g)throw new RangeError("Attempt to allocate Buffer larger than maximum size: 0x"+g.toString(16)+" bytes");return t|0}function Rt(t){return+t!=t&&(t=0),i.alloc(+t)}i.isBuffer=function(t){return t!=null&&t._isBuffer===!0&&t!==i.prototype},i.compare=function(t,e){if(O(t,h)&&(t=i.from(t,t.offset,t.byteLength)),O(e,h)&&(e=i.from(e,e.offset,e.byteLength)),!i.isBuffer(t)||!i.isBuffer(e))throw new TypeError('The "buf1", "buf2" arguments must be one of type Buffer or Uint8Array');if(t===e)return 0;let n=t.length,o=e.length;for(let r=0,f=Math.min(n,o);r<f;++r)if(t[r]!==e[r]){n=t[r],o=e[r];break}return n<o?-1:o<n?1:0},i.isEncoding=function(t){switch(String(t).toLowerCase()){case"hex":case"utf8":case"utf-8":case"ascii":case"latin1":case"binary":case"base64":case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return!0;default:return!1}},i.concat=function(t,e){if(!Array.isArray(t))throw new TypeError('"list" argument must be an Array of Buffers');if(t.length===0)return i.alloc(0);let n;if(e===void 0)for(e=0,n=0;n<t.length;++n)e+=t[n].length;const o=i.allocUnsafe(e);let r=0;for(n=0;n<t.length;++n){let f=t[n];if(O(f,h))r+f.length>o.length?(i.isBuffer(f)||(f=i.from(f)),f.copy(o,r)):h.prototype.set.call(o,f,r);else if(i.isBuffer(f))f.copy(o,r);else throw new TypeError('"list" argument must be an Array of Buffers');r+=f.length}return o};function it(t,e){if(i.isBuffer(t))return t.length;if(l.isView(t)||O(t,l))return t.byteLength;if(typeof t!="string")throw new TypeError('The "string" argument must be one of type string, Buffer, or ArrayBuffer. Received type '+typeof t);const n=t.length,o=arguments.length>2&&arguments[2]===!0;if(!o&&n===0)return 0;let r=!1;for(;;)switch(e){case"ascii":case"latin1":case"binary":return n;case"utf8":case"utf-8":return H(t).length;case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return n*2;case"hex":return n>>>1;case"base64":return dt(t).length;default:if(r)return o?-1:H(t).length;e=(""+e).toLowerCase(),r=!0}}i.byteLength=it;function Ut(t,e,n){let o=!1;if((e===void 0||e<0)&&(e=0),e>this.length||((n===void 0||n>this.length)&&(n=this.length),n<=0)||(n>>>=0,e>>>=0,n<=e))return"";for(t||(t="utf8");;)switch(t){case"hex":return $t(this,e,n);case"utf8":case"utf-8":return ut(this,e,n);case"ascii":return Nt(this,e,n);case"latin1":case"binary":return Pt(this,e,n);case"base64":return Ct(this,e,n);case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return kt(this,e,n);default:if(o)throw new TypeError("Unknown encoding: "+t);t=(t+"").toLowerCase(),o=!0}}i.prototype._isBuffer=!0;function k(t,e,n){const o=t[e];t[e]=t[n],t[n]=o}i.prototype.swap16=function(){const t=this.length;if(t%2!==0)throw new RangeError("Buffer size must be a multiple of 16-bits");for(let e=0;e<t;e+=2)k(this,e,e+1);return this},i.prototype.swap32=function(){const t=this.length;if(t%4!==0)throw new RangeError("Buffer size must be a multiple of 32-bits");for(let e=0;e<t;e+=4)k(this,e,e+3),k(this,e+1,e+2);return this},i.prototype.swap64=function(){const t=this.length;if(t%8!==0)throw new RangeError("Buffer size must be a multiple of 64-bits");for(let e=0;e<t;e+=8)k(this,e,e+7),k(this,e+1,e+6),k(this,e+2,e+5),k(this,e+3,e+4);return this},i.prototype.toString=function(){const t=this.length;return t===0?"":arguments.length===0?ut(this,0,t):Ut.apply(this,arguments)},i.prototype.toLocaleString=i.prototype.toString,i.prototype.equals=function(t){if(!i.isBuffer(t))throw new TypeError("Argument must be a Buffer");return this===t?!0:i.compare(this,t)===0},i.prototype.inspect=function(){let t="";const e=u.INSPECT_MAX_BYTES;return t=this.toString("hex",0,e).replace(/(.{2})/g,"$1 ").trim(),this.length>e&&(t+=" ... "),"<Buffer "+t+">"},p&&(i.prototype[p]=i.prototype.inspect),i.prototype.compare=function(t,e,n,o,r){if(O(t,h)&&(t=i.from(t,t.offset,t.byteLength)),!i.isBuffer(t))throw new TypeError('The "target" argument must be one of type Buffer or Uint8Array. Received type '+typeof t);if(e===void 0&&(e=0),n===void 0&&(n=t?t.length:0),o===void 0&&(o=0),r===void 0&&(r=this.length),e<0||n>t.length||o<0||r>this.length)throw new RangeError("out of range index");if(o>=r&&e>=n)return 0;if(o>=r)return-1;if(e>=n)return 1;if(e>>>=0,n>>>=0,o>>>=0,r>>>=0,this===t)return 0;let f=r-o,s=n-e;const w=Math.min(f,s),T=this.slice(o,r),m=t.slice(e,n);for(let y=0;y<w;++y)if(T[y]!==m[y]){f=T[y],s=m[y];break}return f<s?-1:s<f?1:0};function ft(t,e,n,o,r){if(t.length===0)return-1;if(typeof n=="string"?(o=n,n=0):n>2147483647?n=2147483647:n<-2147483648&&(n=-2147483648),n=+n,Q(n)&&(n=r?0:t.length-1),n<0&&(n=t.length+n),n>=t.length){if(r)return-1;n=t.length-1}else if(n<0)if(r)n=0;else return-1;if(typeof e=="string"&&(e=i.from(e,o)),i.isBuffer(e))return e.length===0?-1:st(t,e,n,o,r);if(typeof e=="number")return e=e&255,typeof h.prototype.indexOf=="function"?r?h.prototype.indexOf.call(t,e,n):h.prototype.lastIndexOf.call(t,e,n):st(t,[e],n,o,r);throw new TypeError("val must be string, number or Buffer")}function st(t,e,n,o,r){let f=1,s=t.length,w=e.length;if(o!==void 0&&(o=String(o).toLowerCase(),o==="ucs2"||o==="ucs-2"||o==="utf16le"||o==="utf-16le")){if(t.length<2||e.length<2)return-1;f=2,s/=2,w/=2,n/=2}function T(y,B){return f===1?y[B]:y.readUInt16BE(B*f)}let m;if(r){let y=-1;for(m=n;m<s;m++)if(T(t,m)===T(e,y===-1?0:m-y)){if(y===-1&&(y=m),m-y+1===w)return y*f}else y!==-1&&(m-=m-y),y=-1}else for(n+w>s&&(n=s-w),m=n;m>=0;m--){let y=!0;for(let B=0;B<w;B++)if(T(t,m+B)!==T(e,B)){y=!1;break}if(y)return m}return-1}i.prototype.includes=function(t,e,n){return this.indexOf(t,e,n)!==-1},i.prototype.indexOf=function(t,e,n){return ft(this,t,e,n,!0)},i.prototype.lastIndexOf=function(t,e,n){return ft(this,t,e,n,!1)};function Lt(t,e,n,o){n=Number(n)||0;const r=t.length-n;o?(o=Number(o),o>r&&(o=r)):o=r;const f=e.length;o>f/2&&(o=f/2);let s;for(s=0;s<o;++s){const w=parseInt(e.substr(s*2,2),16);if(Q(w))return s;t[n+s]=w}return s}function Ot(t,e,n,o){return V(H(e,t.length-n),t,n,o)}function _t(t,e,n,o){return V(zt(e),t,n,o)}function St(t,e,n,o){return V(dt(e),t,n,o)}function xt(t,e,n,o){return V(Gt(e,t.length-n),t,n,o)}i.prototype.write=function(t,e,n,o){if(e===void 0)o="utf8",n=this.length,e=0;else if(n===void 0&&typeof e=="string")o=e,n=this.length,e=0;else if(isFinite(e))e=e>>>0,isFinite(n)?(n=n>>>0,o===void 0&&(o="utf8")):(o=n,n=void 0);else throw new Error("Buffer.write(string, encoding, offset[, length]) is no longer supported");const r=this.length-e;if((n===void 0||n>r)&&(n=r),t.length>0&&(n<0||e<0)||e>this.length)throw new RangeError("Attempt to write outside buffer bounds");o||(o="utf8");let f=!1;for(;;)switch(o){case"hex":return Lt(this,t,e,n);case"utf8":case"utf-8":return Ot(this,t,e,n);case"ascii":case"latin1":case"binary":return _t(this,t,e,n);case"base64":return St(this,t,e,n);case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return xt(this,t,e,n);default:if(f)throw new TypeError("Unknown encoding: "+o);o=(""+o).toLowerCase(),f=!0}},i.prototype.toJSON=function(){return{type:"Buffer",data:Array.prototype.slice.call(this._arr||this,0)}};function Ct(t,e,n){return e===0&&n===t.length?c.fromByteArray(t):c.fromByteArray(t.slice(e,n))}function ut(t,e,n){n=Math.min(t.length,n);const o=[];let r=e;for(;r<n;){const f=t[r];let s=null,w=f>239?4:f>223?3:f>191?2:1;if(r+w<=n){let T,m,y,B;switch(w){case 1:f<128&&(s=f);break;case 2:T=t[r+1],(T&192)===128&&(B=(f&31)<<6|T&63,B>127&&(s=B));break;case 3:T=t[r+1],m=t[r+2],(T&192)===128&&(m&192)===128&&(B=(f&15)<<12|(T&63)<<6|m&63,B>2047&&(B<55296||B>57343)&&(s=B));break;case 4:T=t[r+1],m=t[r+2],y=t[r+3],(T&192)===128&&(m&192)===128&&(y&192)===128&&(B=(f&15)<<18|(T&63)<<12|(m&63)<<6|y&63,B>65535&&B<1114112&&(s=B))}}s===null?(s=65533,w=1):s>65535&&(s-=65536,o.push(s>>>10&1023|55296),s=56320|s&1023),o.push(s),r+=w}return Mt(o)}const ct=4096;function Mt(t){const e=t.length;if(e<=ct)return String.fromCharCode.apply(String,t);let n="",o=0;for(;o<e;)n+=String.fromCharCode.apply(String,t.slice(o,o+=ct));return n}function Nt(t,e,n){let o="";n=Math.min(t.length,n);for(let r=e;r<n;++r)o+=String.fromCharCode(t[r]&127);return o}function Pt(t,e,n){let o="";n=Math.min(t.length,n);for(let r=e;r<n;++r)o+=String.fromCharCode(t[r]);return o}function $t(t,e,n){const o=t.length;(!e||e<0)&&(e=0),(!n||n<0||n>o)&&(n=o);let r="";for(let f=e;f<n;++f)r+=qt[t[f]];return r}function kt(t,e,n){const o=t.slice(e,n);let r="";for(let f=0;f<o.length-1;f+=2)r+=String.fromCharCode(o[f]+o[f+1]*256);return r}i.prototype.slice=function(t,e){const n=this.length;t=~~t,e=e===void 0?n:~~e,t<0?(t+=n,t<0&&(t=0)):t>n&&(t=n),e<0?(e+=n,e<0&&(e=0)):e>n&&(e=n),e<t&&(e=t);const o=this.subarray(t,e);return Object.setPrototypeOf(o,i.prototype),o};function v(t,e,n){if(t%1!==0||t<0)throw new RangeError("offset is not uint");if(t+e>n)throw new RangeError("Trying to access beyond buffer length")}i.prototype.readUintLE=i.prototype.readUIntLE=function(t,e,n){t=t>>>0,e=e>>>0,n||v(t,e,this.length);let o=this[t],r=1,f=0;for(;++f<e&&(r*=256);)o+=this[t+f]*r;return o},i.prototype.readUintBE=i.prototype.readUIntBE=function(t,e,n){t=t>>>0,e=e>>>0,n||v(t,e,this.length);let o=this[t+--e],r=1;for(;e>0&&(r*=256);)o+=this[t+--e]*r;return o},i.prototype.readUint8=i.prototype.readUInt8=function(t,e){return t=t>>>0,e||v(t,1,this.length),this[t]},i.prototype.readUint16LE=i.prototype.readUInt16LE=function(t,e){return t=t>>>0,e||v(t,2,this.length),this[t]|this[t+1]<<8},i.prototype.readUint16BE=i.prototype.readUInt16BE=function(t,e){return t=t>>>0,e||v(t,2,this.length),this[t]<<8|this[t+1]},i.prototype.readUint32LE=i.prototype.readUInt32LE=function(t,e){return t=t>>>0,e||v(t,4,this.length),(this[t]|this[t+1]<<8|this[t+2]<<16)+this[t+3]*16777216},i.prototype.readUint32BE=i.prototype.readUInt32BE=function(t,e){return t=t>>>0,e||v(t,4,this.length),this[t]*16777216+(this[t+1]<<16|this[t+2]<<8|this[t+3])},i.prototype.readBigUInt64LE=P(function(t){t=t>>>0,D(t,"offset");const e=this[t],n=this[t+7];(e===void 0||n===void 0)&&q(t,this.length-8);const o=e+this[++t]*2**8+this[++t]*2**16+this[++t]*2**24,r=this[++t]+this[++t]*2**8+this[++t]*2**16+n*2**24;return BigInt(o)+(BigInt(r)<<BigInt(32))}),i.prototype.readBigUInt64BE=P(function(t){t=t>>>0,D(t,"offset");const e=this[t],n=this[t+7];(e===void 0||n===void 0)&&q(t,this.length-8);const o=e*2**24+this[++t]*2**16+this[++t]*2**8+this[++t],r=this[++t]*2**24+this[++t]*2**16+this[++t]*2**8+n;return(BigInt(o)<<BigInt(32))+BigInt(r)}),i.prototype.readIntLE=function(t,e,n){t=t>>>0,e=e>>>0,n||v(t,e,this.length);let o=this[t],r=1,f=0;for(;++f<e&&(r*=256);)o+=this[t+f]*r;return r*=128,o>=r&&(o-=Math.pow(2,8*e)),o},i.prototype.readIntBE=function(t,e,n){t=t>>>0,e=e>>>0,n||v(t,e,this.length);let o=e,r=1,f=this[t+--o];for(;o>0&&(r*=256);)f+=this[t+--o]*r;return r*=128,f>=r&&(f-=Math.pow(2,8*e)),f},i.prototype.readInt8=function(t,e){return t=t>>>0,e||v(t,1,this.length),this[t]&128?(255-this[t]+1)*-1:this[t]},i.prototype.readInt16LE=function(t,e){t=t>>>0,e||v(t,2,this.length);const n=this[t]|this[t+1]<<8;return n&32768?n|4294901760:n},i.prototype.readInt16BE=function(t,e){t=t>>>0,e||v(t,2,this.length);const n=this[t+1]|this[t]<<8;return n&32768?n|4294901760:n},i.prototype.readInt32LE=function(t,e){return t=t>>>0,e||v(t,4,this.length),this[t]|this[t+1]<<8|this[t+2]<<16|this[t+3]<<24},i.prototype.readInt32BE=function(t,e){return t=t>>>0,e||v(t,4,this.length),this[t]<<24|this[t+1]<<16|this[t+2]<<8|this[t+3]},i.prototype.readBigInt64LE=P(function(t){t=t>>>0,D(t,"offset");const e=this[t],n=this[t+7];(e===void 0||n===void 0)&&q(t,this.length-8);const o=this[t+4]+this[t+5]*2**8+this[t+6]*2**16+(n<<24);return(BigInt(o)<<BigInt(32))+BigInt(e+this[++t]*2**8+this[++t]*2**16+this[++t]*2**24)}),i.prototype.readBigInt64BE=P(function(t){t=t>>>0,D(t,"offset");const e=this[t],n=this[t+7];(e===void 0||n===void 0)&&q(t,this.length-8);const o=(e<<24)+this[++t]*2**16+this[++t]*2**8+this[++t];return(BigInt(o)<<BigInt(32))+BigInt(this[++t]*2**24+this[++t]*2**16+this[++t]*2**8+n)}),i.prototype.readFloatLE=function(t,e){return t=t>>>0,e||v(t,4,this.length),a.read(this,t,!0,23,4)},i.prototype.readFloatBE=function(t,e){return t=t>>>0,e||v(t,4,this.length),a.read(this,t,!1,23,4)},i.prototype.readDoubleLE=function(t,e){return t=t>>>0,e||v(t,8,this.length),a.read(this,t,!0,52,8)},i.prototype.readDoubleBE=function(t,e){return t=t>>>0,e||v(t,8,this.length),a.read(this,t,!1,52,8)};function R(t,e,n,o,r,f){if(!i.isBuffer(t))throw new TypeError('"buffer" argument must be a Buffer instance');if(e>r||e<f)throw new RangeError('"value" argument is out of bounds');if(n+o>t.length)throw new RangeError("Index out of range")}i.prototype.writeUintLE=i.prototype.writeUIntLE=function(t,e,n,o){if(t=+t,e=e>>>0,n=n>>>0,!o){const s=Math.pow(2,8*n)-1;R(this,t,e,n,s,0)}let r=1,f=0;for(this[e]=t&255;++f<n&&(r*=256);)this[e+f]=t/r&255;return e+n},i.prototype.writeUintBE=i.prototype.writeUIntBE=function(t,e,n,o){if(t=+t,e=e>>>0,n=n>>>0,!o){const s=Math.pow(2,8*n)-1;R(this,t,e,n,s,0)}let r=n-1,f=1;for(this[e+r]=t&255;--r>=0&&(f*=256);)this[e+r]=t/f&255;return e+n},i.prototype.writeUint8=i.prototype.writeUInt8=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,1,255,0),this[e]=t&255,e+1},i.prototype.writeUint16LE=i.prototype.writeUInt16LE=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,2,65535,0),this[e]=t&255,this[e+1]=t>>>8,e+2},i.prototype.writeUint16BE=i.prototype.writeUInt16BE=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,2,65535,0),this[e]=t>>>8,this[e+1]=t&255,e+2},i.prototype.writeUint32LE=i.prototype.writeUInt32LE=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,4,4294967295,0),this[e+3]=t>>>24,this[e+2]=t>>>16,this[e+1]=t>>>8,this[e]=t&255,e+4},i.prototype.writeUint32BE=i.prototype.writeUInt32BE=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,4,4294967295,0),this[e]=t>>>24,this[e+1]=t>>>16,this[e+2]=t>>>8,this[e+3]=t&255,e+4};function ht(t,e,n,o,r){wt(e,o,r,t,n,7);let f=Number(e&BigInt(4294967295));t[n++]=f,f=f>>8,t[n++]=f,f=f>>8,t[n++]=f,f=f>>8,t[n++]=f;let s=Number(e>>BigInt(32)&BigInt(4294967295));return t[n++]=s,s=s>>8,t[n++]=s,s=s>>8,t[n++]=s,s=s>>8,t[n++]=s,n}function at(t,e,n,o,r){wt(e,o,r,t,n,7);let f=Number(e&BigInt(4294967295));t[n+7]=f,f=f>>8,t[n+6]=f,f=f>>8,t[n+5]=f,f=f>>8,t[n+4]=f;let s=Number(e>>BigInt(32)&BigInt(4294967295));return t[n+3]=s,s=s>>8,t[n+2]=s,s=s>>8,t[n+1]=s,s=s>>8,t[n]=s,n+8}i.prototype.writeBigUInt64LE=P(function(t,e=0){return ht(this,t,e,BigInt(0),BigInt("0xffffffffffffffff"))}),i.prototype.writeBigUInt64BE=P(function(t,e=0){return at(this,t,e,BigInt(0),BigInt("0xffffffffffffffff"))}),i.prototype.writeIntLE=function(t,e,n,o){if(t=+t,e=e>>>0,!o){const w=Math.pow(2,8*n-1);R(this,t,e,n,w-1,-w)}let r=0,f=1,s=0;for(this[e]=t&255;++r<n&&(f*=256);)t<0&&s===0&&this[e+r-1]!==0&&(s=1),this[e+r]=(t/f>>0)-s&255;return e+n},i.prototype.writeIntBE=function(t,e,n,o){if(t=+t,e=e>>>0,!o){const w=Math.pow(2,8*n-1);R(this,t,e,n,w-1,-w)}let r=n-1,f=1,s=0;for(this[e+r]=t&255;--r>=0&&(f*=256);)t<0&&s===0&&this[e+r+1]!==0&&(s=1),this[e+r]=(t/f>>0)-s&255;return e+n},i.prototype.writeInt8=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,1,127,-128),t<0&&(t=255+t+1),this[e]=t&255,e+1},i.prototype.writeInt16LE=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,2,32767,-32768),this[e]=t&255,this[e+1]=t>>>8,e+2},i.prototype.writeInt16BE=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,2,32767,-32768),this[e]=t>>>8,this[e+1]=t&255,e+2},i.prototype.writeInt32LE=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,4,2147483647,-2147483648),this[e]=t&255,this[e+1]=t>>>8,this[e+2]=t>>>16,this[e+3]=t>>>24,e+4},i.prototype.writeInt32BE=function(t,e,n){return t=+t,e=e>>>0,n||R(this,t,e,4,2147483647,-2147483648),t<0&&(t=4294967295+t+1),this[e]=t>>>24,this[e+1]=t>>>16,this[e+2]=t>>>8,this[e+3]=t&255,e+4},i.prototype.writeBigInt64LE=P(function(t,e=0){return ht(this,t,e,-BigInt("0x8000000000000000"),BigInt("0x7fffffffffffffff"))}),i.prototype.writeBigInt64BE=P(function(t,e=0){return at(this,t,e,-BigInt("0x8000000000000000"),BigInt("0x7fffffffffffffff"))});function lt(t,e,n,o,r,f){if(n+o>t.length)throw new RangeError("Index out of range");if(n<0)throw new RangeError("Index out of range")}function pt(t,e,n,o,r){return e=+e,n=n>>>0,r||lt(t,e,n,4),a.write(t,e,n,o,23,4),n+4}i.prototype.writeFloatLE=function(t,e,n){return pt(this,t,e,!0,n)},i.prototype.writeFloatBE=function(t,e,n){return pt(this,t,e,!1,n)};function gt(t,e,n,o,r){return e=+e,n=n>>>0,r||lt(t,e,n,8),a.write(t,e,n,o,52,8),n+8}i.prototype.writeDoubleLE=function(t,e,n){return gt(this,t,e,!0,n)},i.prototype.writeDoubleBE=function(t,e,n){return gt(this,t,e,!1,n)},i.prototype.copy=function(t,e,n,o){if(!i.isBuffer(t))throw new TypeError("argument should be a Buffer");if(n||(n=0),!o&&o!==0&&(o=this.length),e>=t.length&&(e=t.length),e||(e=0),o>0&&o<n&&(o=n),o===n||t.length===0||this.length===0)return 0;if(e<0)throw new RangeError("targetStart out of bounds");if(n<0||n>=this.length)throw new RangeError("Index out of range");if(o<0)throw new RangeError("sourceEnd out of bounds");o>this.length&&(o=this.length),t.length-e<o-n&&(o=t.length-e+n);const r=o-n;return this===t&&typeof h.prototype.copyWithin=="function"?this.copyWithin(e,n,o):h.prototype.set.call(t,this.subarray(n,o),e),r},i.prototype.fill=function(t,e,n,o){if(typeof t=="string"){if(typeof e=="string"?(o=e,e=0,n=this.length):typeof n=="string"&&(o=n,n=this.length),o!==void 0&&typeof o!="string")throw new TypeError("encoding must be a string");if(typeof o=="string"&&!i.isEncoding(o))throw new TypeError("Unknown encoding: "+o);if(t.length===1){const f=t.charCodeAt(0);(o==="utf8"&&f<128||o==="latin1")&&(t=f)}}else typeof t=="number"?t=t&255:typeof t=="boolean"&&(t=Number(t));if(e<0||this.length<e||this.length<n)throw new RangeError("Out of range index");if(n<=e)return this;e=e>>>0,n=n===void 0?this.length:n>>>0,t||(t=0);let r;if(typeof t=="number")for(r=e;r<n;++r)this[r]=t;else{const f=i.isBuffer(t)?t:i.from(t,o),s=f.length;if(s===0)throw new TypeError('The value "'+t+'" is invalid for argument "value"');for(r=0;r<n-e;++r)this[r+e]=f[r%s]}return this};const F={};function Z(t,e,n){F[t]=class extends n{constructor(){super(),Object.defineProperty(this,"message",{value:e.apply(this,arguments),writable:!0,configurable:!0}),this.name=`${this.name} [${t}]`,this.stack,delete this.name}get code(){return t}set code(o){Object.defineProperty(this,"code",{configurable:!0,enumerable:!0,value:o,writable:!0})}toString(){return`${this.name} [${t}]: ${this.message}`}}}Z("ERR_BUFFER_OUT_OF_BOUNDS",function(t){return t?`${t} is outside of buffer bounds`:"Attempt to access memory outside buffer bounds"},RangeError),Z("ERR_INVALID_ARG_TYPE",function(t,e){return`The "${t}" argument must be of type number. Received type ${typeof e}`},TypeError),Z("ERR_OUT_OF_RANGE",function(t,e,n){let o=`The value of "${t}" is out of range.`,r=n;return Number.isInteger(n)&&Math.abs(n)>2**32?r=yt(String(n)):typeof n=="bigint"&&(r=String(n),(n>BigInt(2)**BigInt(32)||n<-(BigInt(2)**BigInt(32)))&&(r=yt(r)),r+="n"),o+=` It must be ${e}. Received ${r}`,o},RangeError);function yt(t){let e="",n=t.length;const o=t[0]==="-"?1:0;for(;n>=o+4;n-=3)e=`_${t.slice(n-3,n)}${e}`;return`${t.slice(0,n)}${e}`}function jt(t,e,n){D(e,"offset"),(t[e]===void 0||t[e+n]===void 0)&&q(e,t.length-(n+1))}function wt(t,e,n,o,r,f){if(t>n||t<e){const s=typeof e=="bigint"?"n":"";let w;throw e===0||e===BigInt(0)?w=`>= 0${s} and < 2${s} ** ${(f+1)*8}${s}`:w=`>= -(2${s} ** ${(f+1)*8-1}${s}) and < 2 ** ${(f+1)*8-1}${s}`,new F.ERR_OUT_OF_RANGE("value",w,t)}jt(o,r,f)}function D(t,e){if(typeof t!="number")throw new F.ERR_INVALID_ARG_TYPE(e,"number",t)}function q(t,e,n){throw Math.floor(t)!==t?(D(t,n),new F.ERR_OUT_OF_RANGE("offset","an integer",t)):e<0?new F.ERR_BUFFER_OUT_OF_BOUNDS:new F.ERR_OUT_OF_RANGE("offset",`>= 0 and <= ${e}`,t)}const Ft=/[^+/0-9A-Za-z-_]/g;function Dt(t){if(t=t.split("=")[0],t=t.trim().replace(Ft,""),t.length<2)return"";for(;t.length%4!==0;)t=t+"=";return t}function H(t,e){e=e||1/0;let n;const o=t.length;let r=null;const f=[];for(let s=0;s<o;++s){if(n=t.charCodeAt(s),n>55295&&n<57344){if(!r){if(n>56319){(e-=3)>-1&&f.push(239,191,189);continue}else if(s+1===o){(e-=3)>-1&&f.push(239,191,189);continue}r=n;continue}if(n<56320){(e-=3)>-1&&f.push(239,191,189),r=n;continue}n=(r-55296<<10|n-56320)+65536}else r&&(e-=3)>-1&&f.push(239,191,189);if(r=null,n<128){if((e-=1)<0)break;f.push(n)}else if(n<2048){if((e-=2)<0)break;f.push(n>>6|192,n&63|128)}else if(n<65536){if((e-=3)<0)break;f.push(n>>12|224,n>>6&63|128,n&63|128)}else if(n<1114112){if((e-=4)<0)break;f.push(n>>18|240,n>>12&63|128,n>>6&63|128,n&63|128)}else throw new Error("Invalid code point")}return f}function zt(t){const e=[];for(let n=0;n<t.length;++n)e.push(t.charCodeAt(n)&255);return e}function Gt(t,e){let n,o,r;const f=[];for(let s=0;s<t.length&&!((e-=2)<0);++s)n=t.charCodeAt(s),o=n>>8,r=n%256,f.push(r),f.push(o);return f}function dt(t){return c.toByteArray(Dt(t))}function V(t,e,n,o){let r;for(r=0;r<o&&!(r+n>=e.length||r>=t.length);++r)e[r+n]=t[r];return r}function O(t,e){return t instanceof e||t!=null&&t.constructor!=null&&t.constructor.name!=null&&t.constructor.name===e.name}function Q(t){return t!==t}const qt=function(){const t="0123456789abcdef",e=new Array(256);for(let n=0;n<16;++n){const o=n*16;for(let r=0;r<16;++r)e[o+r]=t[n]+t[r]}return e}();function P(t){return typeof BigInt>"u"?Vt:t}function Vt(){throw new Error("BigInt not supported")}})(mt);const te=mt.Buffer;function ee(u){return u&&u.__esModule&&Object.prototype.hasOwnProperty.call(u,"default")?u.default:u}var Et={exports:{}},b=Et.exports={},S,x;function nt(){throw new Error("setTimeout has not been defined")}function ot(){throw new Error("clearTimeout has not been defined")}(function(){try{typeof setTimeout=="function"?S=setTimeout:S=nt}catch{S=nt}try{typeof clearTimeout=="function"?x=clearTimeout:x=ot}catch{x=ot}})();function Bt(u){if(S===setTimeout)return setTimeout(u,0);if((S===nt||!S)&&setTimeout)return S=setTimeout,setTimeout(u,0);try{return S(u,0)}catch{try{return S.call(null,u,0)}catch{return S.call(this,u,0)}}}function ne(u){if(x===clearTimeout)return clearTimeout(u);if((x===ot||!x)&&clearTimeout)return x=clearTimeout,clearTimeout(u);try{return x(u)}catch{try{return x.call(null,u)}catch{return x.call(this,u)}}}var M=[],G=!1,j,W=-1;function oe(){!G||!j||(G=!1,j.length?M=j.concat(M):W=-1,M.length&&vt())}function vt(){if(!G){var u=Bt(oe);G=!0;for(var c=M.length;c;){for(j=M,M=[];++W<c;)j&&j[W].run();W=-1,c=M.length}j=null,G=!1,ne(u)}}b.nextTick=function(u){var c=new Array(arguments.length-1);if(arguments.length>1)for(var a=1;a<arguments.length;a++)c[a-1]=arguments[a];M.push(new It(u,c)),M.length===1&&!G&&Bt(vt)};function It(u,c){this.fun=u,this.array=c}It.prototype.run=function(){this.fun.apply(null,this.array)},b.title="browser",b.browser=!0,b.env={},b.argv=[],b.version="",b.versions={};function N(){}b.on=N,b.addListener=N,b.once=N,b.off=N,b.removeListener=N,b.removeAllListeners=N,b.emit=N,b.prependListener=N,b.prependOnceListener=N,b.listeners=function(u){return[]},b.binding=function(u){throw new Error("process.binding is not supported")},b.cwd=function(){return"/"},b.chdir=function(u){throw new Error("process.chdir is not supported")},b.umask=function(){return 0};var re=Et.exports;const ie=ee(re);window.Buffer=te,window.process=ie;
