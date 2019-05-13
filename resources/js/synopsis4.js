/*Handles zooming into pictures: woodcut and facsimile.*/

function zoomFacsL() {
/*Is called when mouse enters image. Zoom for facsimile gallery*/
	$('#zoom_01_l').ezPlus({
		gallery: 'gallery_01_l',
		cursor: 'pointer',
		galleryActiveClass: "active",
		imageCrossfade: true,
		loadingIcon: "img/loader.gif",
		zoomType: 'lens',
		lensShape: 'round', //can be 'round'
		lensSize: 350,
		scrollZoom: true,
		zoomContainerAppendTo: 'div.myPicturesL'
	});
	
	$('#zoom_01_l').bind("click", function (e) {
		var ez = $('#zoom_01_l').data('ezPlus');
		ez.closeAll();
		$.fancybox(ez.getGalleryList());
		return false;
	});
};

function zoomFacsR() {
/*Is called when mouse enters image. Zoom for facsimile gallery*/
	$('#zoom_01_r').ezPlus({
		gallery: 'gallery_01_r',
		cursor: 'pointer',
		galleryActiveClass: "active",
		imageCrossfade: true,
		loadingIcon: "img/loader.gif",
		zoomType: 'lens',
		lensShape: 'round', //can be 'round'
		lensSize: 350,
		scrollZoom: true,
		zoomContainerAppendTo: 'div.myPicturesR'
	});
	
	$('#zoom_01_r').bind("click", function (e) {
		var ez = $('#zoom_01_r').data('ezPlus');
		ez.closeAll();
		$.fancybox(ez.getGalleryList());
		return false;
	});
};

function zoomWoodL() {
/*Is called when mouse enters image. Zoom for woodcuts.*/
	$("#woodcut-zoom-l").ezPlus({
		cursor: 'pointer',
		loadingIcon: "img/loader.gif",
		zoomType: 'lens',
		lensShape: 'round', //can be 'round'
		lensSize: 350,
		scrollZoom: true,
		zoomContainerAppendTo: 'div.myWoodcutL'
	});
};

function zoomWoodR() {
/*Is called when mouse enters image. Zoom for woodcuts.*/
	$("#woodcut-zoom-r").ezPlus({
		cursor: 'pointer',
		loadingIcon: "img/loader.gif",
		zoomType: 'lens',
		lensShape: 'round', //can be 'round'
		lensSize: 350,
		scrollZoom: true,
		zoomContainerAppendTo: 'div.myWoodcutR'
	});
};