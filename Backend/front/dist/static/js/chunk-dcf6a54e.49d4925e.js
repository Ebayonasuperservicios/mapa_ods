(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["chunk-dcf6a54e"],{"19d6":function(t,e,a){"use strict";a.r(e);var s=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"dashboard-editor-container"},[a("el-row",{attrs:{gutter:8}},[a("el-col",{staticStyle:{"padding-right":"8px","margin-bottom":"30px"},attrs:{xs:{span:24},sm:{span:24},md:{span:24},lg:{span:24},xl:{span:24}}},[a("div",{staticClass:"block"},[a("el-date-picker",{attrs:{type:"month",align:"right",placeholder:t.$t("datePicker.date")},on:{change:function(e){return t.dateChange(e)}},model:{value:t.date,callback:function(e){t.date=e},expression:"date"}}),t._v(" "),a("el-tag",{attrs:{type:"warning"}},[t._v("\n          Datos actualizados a fecha de "+t._s(t.printLastDate())+"\n        ")])],1),t._v(" "),a("h2",[t._v(" "+t._s(t.$t("route.pm"))+" ")]),t._v(" "),a("el-row",{attrs:{gutter:32}},[a("el-col",{attrs:{xs:24,sm:24,lg:24}},[a("div",{staticClass:"chart-wrapper"},[a("pie-chart",{attrs:{data:t.list,"value-title":"Valor"}})],1)])],1),t._v(" "),a("transaction-table",{attrs:{data:t.list,"indicator-name":t.indicatorName,"item-title":"Planta","description-title":"Agente","value-title":"Porcentaje en participacion","value2-title":"Cantidades contratadas",date:t.date,status:t.status,value:t.value}})],1)],1)],1)},n=[],r=(a("96cf"),a("1da1")),i=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{class:t.className,style:{height:t.height,width:t.width}})},c=[],l=(a("ac6a"),a("313e")),d=a.n(l),o=a("ed08");a("817d");var u=3e3,f={props:{data:{type:Array,default:function(){return[]}},valueTitle:{type:String,default:"Valor"},className:{type:String,default:"chart"},width:{type:String,default:"100%"},height:{type:String,default:"600px"}},data:function(){return{chart:null}},watch:{data:function(t,e){var a=this;this.initChart(t),this.__resizeHandler=Object(o["b"])((function(){a.chart&&a.chart.resize()}),100),window.addEventListener("resize",this.__resizeHandler)}},beforeDestroy:function(){this.chart&&(window.removeEventListener("resize",this.__resizeHandler),this.chart.dispose(),this.chart=null)},methods:{initChart:function(t){if(this.chart=d.a.init(this.$el,"macarons"),t){for(var e=[],a=0;a<t.length;a++)e.push({value:t[a].values[0],name:t[a].names[0]});this.chart.setOption({backgroundColor:"#344b58",series:[{name:this.valueTitle,type:"pie",stack:"vistors",radius:"70%",data:e,animationDuration:u,label:{formatter:"{b}:  {d}%"}}]})}}}},b=f,h=a("2877"),j=Object(h["a"])(b,i,c,!1,null,null,null),m=j.exports,p=function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"transction-table"},[a("el-row",{staticStyle:{background:"#fff",padding:"16px 16px 0","margin-bottom":"32px"}},[a("el-collapse",[a("el-collapse-item",{attrs:{title:"Descripción del indicador",name:"1"}},[a("ul",[a("li",[t._v("\n            Corresponde al porcentaje de participación de cada productor sobre la contratación en firme total del mercado.\n          ")])])])],1)],1),t._v(" "),a("el-button",{staticStyle:{margin:"0 0 20px 20px"},attrs:{loading:t.downloadLoading,type:"primary",icon:"document"},on:{click:t.handleDownload}},[t._v("\n    "+t._s(t.$t("excel.export"))+" Excel\n  ")]),t._v(" "),a("el-table",{staticStyle:{width:"100%","padding-top":"15px"},attrs:{data:t.format(t.data)}},[a("el-table-column",{attrs:{label:t.descriptionTitle,"min-width":"150",prop:"name0",sortable:""},scopedSlots:t._u([{key:"default",fn:function(e){return[t._v("\n        "+t._s(e.row.name0)+"\n      ")]}}])}),t._v(" "),a("el-table-column",{attrs:{label:t.value2Title,width:"230",align:"center",prop:"value",sortable:""},scopedSlots:t._u([{key:"default",fn:function(e){return[t._v("\n        "+t._s(Number(e.row.value1))+"\n      ")]}}])}),t._v(" "),a("el-table-column",{attrs:{label:t.valueTitle,width:"230",align:"center",prop:"value",sortable:""},scopedSlots:t._u([{key:"default",fn:function(e){return[t._v("\n        "+t._s(Number(e.row.value0).toFixed(2))+"  %\n      ")]}}])})],1)],1)},v=[],g=(a("c5f6"),a("c1df")),y=a.n(g),w=["success","warning","danger"],k={filters:{trafficLightStatusFilter:function(t){return w[t]}},props:{data:{type:Array,default:function(){return[]}},indicatorName:{type:String,default:"preofe"},itemTitle:{type:String,default:"Item"},descriptionTitle:{type:String,default:"Descripción"},valueTitle:{type:String,default:"Valor"},value2Title:{type:String,default:"Valor"},units:{type:String,default:"Cantidad"},statusTitle:{type:String,default:"Estado"},date:{type:Date,default:new Date},status:{type:Boolean,default:!1},value:{type:Number,default:0}},data:function(){return{chart:null,showImage:!1,downloadLoading:!1}},methods:{formatJson:function(t,e){return e.map((function(e){return t.map((function(t){return e[t]}))}))},handleDownload:function(){var t=this;this.downloadLoading=!0,Promise.all([a.e("chunk-412797d4"),a.e("chunk-a47188ce")]).then(a.bind(null,"4bf8d")).then((function(e){var a=[t.descriptionTitle,t.value2Title,t.valueTitle],s=["index","value1","value0"],n=t.format(t.data),r=t.formatJson(s,n);e.export_json_to_excel({header:a,data:r,filename:t.indicatorName,autoWidth:t.autoWidth,bookType:t.bookType}),t.downloadLoading=!1}))},format:function(t){for(var e=[],a=0;a<t.length;a++)e.push({index:t[a].id,name0:t[a].names[0],name1:t[a].names[1],value0:t[a].values[0],value1:t[a].values[1],status:t[a].status});return e},formatDate:function(t){return y()(t).format("DD-MM-YYYY")}}},_=k,D=(a("9324"),Object(h["a"])(_,p,v,!1,null,"6b63d756",null)),x=D.exports,z=a("820e"),S={name:"DashboardAdmin",components:{PieChart:m,TransactionTable:x},data:function(){return{indicatorName:"gmp",date:new Date,list:[],status:!1,value:0}},created:function(){this.fetchLatest()},methods:{printLastDate:function(){return y()(this.lastDate).format("DD/MM/YYYY")},formatDate:function(t){return y()(t).format("DD-MM-YYYY")},dateChange:function(t){this.getData()},measureChange:function(t){this.type=t,this.getData()},fetchLatest:function(){var t=Object(r["a"])(regeneratorRuntime.mark((function t(){var e;return regeneratorRuntime.wrap((function(t){while(1)switch(t.prev=t.next){case 0:return t.prev=0,t.next=3,Object(z["b"])("gmg");case 3:e=t.sent,this.lastDate=new Date(e[1]),this.initDate=new Date(e[0]),this.date=this.lastDate,t.next=13;break;case 9:t.prev=9,t.t0=t["catch"](0),this.date=new Date,console.error(t.t0);case 13:this.getData();case 14:case"end":return t.stop()}}),t,this,[[0,9]])})));function e(){return t.apply(this,arguments)}return e}(),getData:function(){var t=Object(r["a"])(regeneratorRuntime.mark((function t(){var e;return regeneratorRuntime.wrap((function(t){while(1)switch(t.prev=t.next){case 0:return t.prev=0,(this.date>this.lastDate||this.date<this.initDate)&&(this.date=this.lastDate),t.next=4,Object(z["a"])(this.indicatorName,{fecha:this.formatDate(this.date)});case 4:e=t.sent,e&&(this.list=e.items,this.status=e.status,this.value=e.value),t.next=12;break;case 8:t.prev=8,t.t0=t["catch"](0),this.list=[],this.value=0;case 12:case"end":return t.stop()}}),t,this,[[0,8]])})));function e(){return t.apply(this,arguments)}return e}()}},T=S,C=(a("3aac"),Object(h["a"])(T,s,n,!1,null,"097e6d1c",null));e["default"]=C.exports},"3aac":function(t,e,a){"use strict";var s=a("e2c0"),n=a.n(s);n.a},4678:function(t,e,a){var s={"./af":"2bfb","./af.js":"2bfb","./ar":"8e73","./ar-dz":"a356","./ar-dz.js":"a356","./ar-kw":"423e","./ar-kw.js":"423e","./ar-ly":"1cfd","./ar-ly.js":"1cfd","./ar-ma":"0a84","./ar-ma.js":"0a84","./ar-sa":"8230","./ar-sa.js":"8230","./ar-tn":"6d83","./ar-tn.js":"6d83","./ar.js":"8e73","./az":"485c","./az.js":"485c","./be":"1fc1","./be.js":"1fc1","./bg":"84aa","./bg.js":"84aa","./bm":"a7fa","./bm.js":"a7fa","./bn":"9043","./bn.js":"9043","./bo":"d26a","./bo.js":"d26a","./br":"6887","./br.js":"6887","./bs":"2554","./bs.js":"2554","./ca":"d716","./ca.js":"d716","./cs":"3c0d","./cs.js":"3c0d","./cv":"03ec","./cv.js":"03ec","./cy":"9797","./cy.js":"9797","./da":"0f14","./da.js":"0f14","./de":"b469","./de-at":"b3eb","./de-at.js":"b3eb","./de-ch":"bb71","./de-ch.js":"bb71","./de.js":"b469","./dv":"598a","./dv.js":"598a","./el":"8d47","./el.js":"8d47","./en-au":"0e6b","./en-au.js":"0e6b","./en-ca":"3886","./en-ca.js":"3886","./en-gb":"39a6","./en-gb.js":"39a6","./en-ie":"e1d3","./en-ie.js":"e1d3","./en-il":"73332","./en-il.js":"73332","./en-in":"ec2e","./en-in.js":"ec2e","./en-nz":"6f50","./en-nz.js":"6f50","./en-sg":"b7e9","./en-sg.js":"b7e9","./eo":"65db","./eo.js":"65db","./es":"898b","./es-do":"0a3c","./es-do.js":"0a3c","./es-us":"55c9","./es-us.js":"55c9","./es.js":"898b","./et":"ec18","./et.js":"ec18","./eu":"0ff2","./eu.js":"0ff2","./fa":"8df48","./fa.js":"8df48","./fi":"81e9","./fi.js":"81e9","./fil":"d69a","./fil.js":"d69a","./fo":"0721","./fo.js":"0721","./fr":"9f26","./fr-ca":"d9f8","./fr-ca.js":"d9f8","./fr-ch":"0e49","./fr-ch.js":"0e49","./fr.js":"9f26","./fy":"7118","./fy.js":"7118","./ga":"5120","./ga.js":"5120","./gd":"f6b46","./gd.js":"f6b46","./gl":"8840","./gl.js":"8840","./gom-deva":"aaf2","./gom-deva.js":"aaf2","./gom-latn":"0caa","./gom-latn.js":"0caa","./gu":"e0c5","./gu.js":"e0c5","./he":"c7aa","./he.js":"c7aa","./hi":"dc4d","./hi.js":"dc4d","./hr":"4ba9","./hr.js":"4ba9","./hu":"5b14","./hu.js":"5b14","./hy-am":"d6b6","./hy-am.js":"d6b6","./id":"5038","./id.js":"5038","./is":"0558","./is.js":"0558","./it":"6e98","./it-ch":"6f12","./it-ch.js":"6f12","./it.js":"6e98","./ja":"079e","./ja.js":"079e","./jv":"b540","./jv.js":"b540","./ka":"201b","./ka.js":"201b","./kk":"6d79","./kk.js":"6d79","./km":"e81d","./km.js":"e81d","./kn":"3e92","./kn.js":"3e92","./ko":"22f8","./ko.js":"22f8","./ku":"2421","./ku.js":"2421","./ky":"9609","./ky.js":"9609","./lb":"440c","./lb.js":"440c","./lo":"b29d","./lo.js":"b29d","./lt":"26f9","./lt.js":"26f9","./lv":"b97c","./lv.js":"b97c","./me":"293c","./me.js":"293c","./mi":"688b","./mi.js":"688b","./mk":"6909","./mk.js":"6909","./ml":"02fb","./ml.js":"02fb","./mn":"958b","./mn.js":"958b","./mr":"39bd","./mr.js":"39bd","./ms":"ebe4","./ms-my":"6403","./ms-my.js":"6403","./ms.js":"ebe4","./mt":"1b45","./mt.js":"1b45","./my":"8689","./my.js":"8689","./nb":"6ce3","./nb.js":"6ce3","./ne":"3a39","./ne.js":"3a39","./nl":"facd","./nl-be":"db29","./nl-be.js":"db29","./nl.js":"facd","./nn":"b84c","./nn.js":"b84c","./oc-lnc":"167b","./oc-lnc.js":"167b","./pa-in":"f3ff","./pa-in.js":"f3ff","./pl":"8d57","./pl.js":"8d57","./pt":"f260","./pt-br":"d2d4","./pt-br.js":"d2d4","./pt.js":"f260","./ro":"972c","./ro.js":"972c","./ru":"957c","./ru.js":"957c","./sd":"6784","./sd.js":"6784","./se":"ffff","./se.js":"ffff","./si":"eda5","./si.js":"eda5","./sk":"7be6","./sk.js":"7be6","./sl":"8155","./sl.js":"8155","./sq":"c8f3","./sq.js":"c8f3","./sr":"cf1e9","./sr-cyrl":"13e9","./sr-cyrl.js":"13e9","./sr.js":"cf1e9","./ss":"52bd","./ss.js":"52bd","./sv":"5fbd","./sv.js":"5fbd","./sw":"74dc","./sw.js":"74dc","./ta":"3de5","./ta.js":"3de5","./te":"5cbb","./te.js":"5cbb","./tet":"576c","./tet.js":"576c","./tg":"3b1b","./tg.js":"3b1b","./th":"10e8","./th.js":"10e8","./tl-ph":"0f38","./tl-ph.js":"0f38","./tlh":"cf75","./tlh.js":"cf75","./tr":"0e81","./tr.js":"0e81","./tzl":"cf51","./tzl.js":"cf51","./tzm":"c109","./tzm-latn":"b53d","./tzm-latn.js":"b53d","./tzm.js":"c109","./ug-cn":"6117","./ug-cn.js":"6117","./uk":"ada2","./uk.js":"ada2","./ur":"5294","./ur.js":"5294","./uz":"2e8c","./uz-latn":"010e","./uz-latn.js":"010e","./uz.js":"2e8c","./vi":"2921","./vi.js":"2921","./x-pseudo":"fd7e","./x-pseudo.js":"fd7e","./yo":"7f33","./yo.js":"7f33","./zh-cn":"5c3a","./zh-cn.js":"5c3a","./zh-hk":"49ab","./zh-hk.js":"49ab","./zh-mo":"3a6c","./zh-mo.js":"3a6c","./zh-tw":"90ea","./zh-tw.js":"90ea"};function n(t){var e=r(t);return a(e)}function r(t){var e=s[t];if(!(e+1)){var a=new Error("Cannot find module '"+t+"'");throw a.code="MODULE_NOT_FOUND",a}return e}n.keys=function(){return Object.keys(s)},n.resolve=r,t.exports=n,n.id="4678"},"820e":function(t,e,a){"use strict";a.d(e,"a",(function(){return n})),a.d(e,"b",(function(){return r}));var s=a("b775");function n(t,e){return Object(s["a"])({url:"/indicadores/".concat(t),method:"get",params:e})}function r(t){return Object(s["a"])({url:"/indicadores/indicador",method:"get",params:{nombre:t}})}},9324:function(t,e,a){"use strict";var s=a("b0f3"),n=a.n(s);n.a},b0f3:function(t,e,a){},e2c0:function(t,e,a){}}]);