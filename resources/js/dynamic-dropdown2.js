$(document).ready(function () {
	load_json_data('ausgabe2');
	function load_json_data(id, parent_id) {
		var html_code = '';
		
		/* Lade json-Datei */
		$.getJSON('resources/json/dynamic-dropdown.json', function (data) {
			/* Variablen für reguläre Ausdrücke */
			var para = /[GW][0-9]+P[0-9]+n[0-9]/,
			para2 = /[GW][0-9]+B[0-9]+n[0-9]/,
			facs = /facs/,
			reg = /reg/,
			orig = /orig/
			
			html_code += '<option value=""/>';
			$.each(data, function (key, value) {
				if (id.match(/ausgabe[0-9]/)) {
					if (value.parent_id == '0') {
						html_code += '<option value="' + value.name + '" id="' + value.id + '">' + value.title + '</option>';
					}
				} else {
					if (value.parent_id == parent_id) {
						/*if (value.name.match(reg)) {
							html_code += '<option value="' + value.name.replace(/GW[0-9]+[A-Z][0-9]+n[0-9]+([a-z]+)/g, "$1") + '" id="' + value.id + '">Lesetext</option>';
						} else if (value.name.match(orig)) {
							html_code += '<option value="' + value.name.replace(/GW[0-9]+[A-Z][0-9]+n[0-9]+([a-z]+)/g, "$1") + '" id="' + value.id + '">Transkription</option>';
						} else if (value.name.match(facs)) {
							html_code += '<option value="' + value.name.replace(/GW[0-9]+[A-Z][0-9]+n[0-9]+([a-z]+)/g, "$1") + '" id="' + value.id + '">Faksimile</option>';
						} */
						if (value.name.match(para)) {
							html_code += '<option value="' + value.name.replace(/(GW[0-9]+)[PB][0-9]+(n[0-9]+)/g, "$1$2") + '" id="' + value.id + '">Paratext ' + value.name.replace(/GW[0-9]+[PB]([0-9]+)n[0-9]+/g, "$1") + '</option>';
						} else if (value.name.match(para2)) {
							html_code += '<option value="' + value.name.replace(/(GW[0-9]+)[PB][0-9]+(n[0-9]+)/g, "$1$2") + '" id="' + value.id + '" type=' + value.name + '>Kapitel ' + value.name.replace(/GW[0-9]+[PB]([0-9]+)n[0-9]+/g, "$1") + '</option>';
						} else {
							html_code += '<option value="' + value.id + '">' + value.name + '</option>';
						}
					}
				}
			});
			$('#' + id).html(html_code);
			$('#' + id).trigger("chosen:updated");
		});
	}
	
	$(document).on('change', '#ausgabe2', function () {
		var ausgabe_id = $(this).find('option:selected').attr('id');
		var book = $(this).find('option:selected').text();
		localStorage.setItem('book2', book);
		if (ausgabe_id != '') {
			load_json_data('kapitel2', ausgabe_id);
		} else {
			$('#kapitel2').html('<option value="">Kapitel wählen</option>');
			/*$('#ansicht1').html('<option value="">Ansicht wählen</option>');*/
		}		
	});
	
	$(document).on('change', '#kapitel2', function () {
		/*var kapitel_id = $(this).find('option:selected').attr('id');*/
		var chap = $(this).find('option:selected').text();
		localStorage.setItem('chap2', chap);
	/*	if (kapitel_id != '') {
			load_json_data('ansicht1', kapitel_id);
		} else {
			$('#ansicht1').html('<option value="">Ansicht wählen</option>');
		}	*/	
	});
	
	/*$(document).on('change', '#ansicht1', function () {
		var vers = $(this).find('option:selected').text();
		localStorage.setItem('vers1', vers);
	});*/
});

$(document).ready(function () {
	var x = localStorage.getItem('chap2');
	var y = localStorage.getItem('book2');
	/*var z = localStorage.getItem('vers1');*/
	var d = document.getElementById("kapitel2"); 
	var e = document.getElementById('ausgabe2');
	/*var f = document.getElementById('ansicht1');*/
	if(x && y){
		d.setAttribute("data-placeholder", x);	
		e.setAttribute("data-placeholder", y);
		/*f.setAttribute("data-placeholder", z);*/
	}
	$('#kapitel2').trigger("chosen:updated");
	$('#ausgabe2').trigger("chosen:updated");
	/*$('#ansicht1').trigger("chosen:updated");*/
});