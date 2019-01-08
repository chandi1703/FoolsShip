function cite(){
    $(function () {  
    var dummy = document.createElement('input'),
        now = new Date(),
        text = window.location.href;   
    document.body.appendChild(dummy);
    dummy.value = text + " " + now;
    dummy.select();
    document.execCommand('copy');
    document.body.removeChild(dummy);
})};