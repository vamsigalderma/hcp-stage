//Cookie Script
document.write('<script type="text/javascript" src="https://cdn.cookielaw.org/consent/e06905fe-68e6-4b4d-8405-3d42b6e3ec1e/OtAutoBlock.js" ></script>');
document.write('<script type="text/javascript" src="https://cdn.cookielaw.org/scripttemplates/otSDKStub.js" charset="UTF-8" data-domain-script="e06905fe-68e6-4b4d-8405-3d42b6e3ec1e"></script>');
function OptanonWrapper(){}
//GTM Code
(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-MD2R269');
var verifyCallback = function(token) {
    window.parent.document.dispatchEvent(new CustomEvent('grecaptchaVerified', {'detail': {response: token}}));
};
var expireCallback = function() {
    window.parent.document.dispatchEvent(new Event('grecaptchaExpired'));
};
var errorCallback = function() {
    window.parent.document.dispatchEvent(new Event('grecaptchaError'));
};
document.addEventListener('grecaptchaRender', function(e) {
    grecaptcha.render(e.detail.element, {
        'sitekey': '6LftnnEpAAAAAJAA0_iRHm-OnBy0EnNO95lDDXZZ',
        'callback': verifyCallback,
        'expired-callback': expireCallback,
        'error-callback': errorCallback
    });
    
   
});
document.addEventListener('grecaptchaReset', function() {
    grecaptcha.reset();
}); 
