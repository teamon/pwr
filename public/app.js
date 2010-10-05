tr = '<tr>\
	<td class="name"><a href="#">X</a> <input type="text" value="" /></td>\
	<td class="ects"><input type="text" value="" /></td>\
	<td class="grade"><input type="text" value="" /></td>\
</tr>'


function format(i){
    if(i<10) return "0" + i
    else return "" + i
}

function hours(){
    opts = ""
    
    for(var h=7; h<=21; h++){
        for(var m=0; m<=55; m+=5){
            var v = format(h) + ':' + format(m)
            opts += '<option value="'+v+'">'+v+'</option>'
        }        
    }
    
    return opts;
}

function ptr(i){
    return '<tr>\
    	<td class="name"><a href="#">X</a> <input type="text" name="more[' + i + '][name]" value="" /></td>\
    	<td class="type">\
    	    <select name="more[' + i + '][type]">\
                <option value="W">Wyk.</option>\
                <option value="C">Ćw.</option>\
                <option value="L">Lab.</option>\
                <option value="P">Proj.</option>\
                <option value="S">Sem.</option>\
                <option value="X">---</option>\
    	    </select>\
    	</td>\
    	<td class="week">\
    	    <select name="more[' + i + '][week]">\
    	        <option value="">T</option>\
    	        <option value="TN">TN</option>\
    	        <option value="TP">TP</option>\
    	    </select>\
    	</td>\
    	<td class="day">\
    	    <select name="more[' + i + '][day]">\
                <option value="0">pn</option>\
                <option value="1">wt</option>\
                <option value="2">śr</option>\
                <option value="3">czw</option>\
                <option value="4">pt</option>\
    	    </select>\
    	</td>\
    	<td class="hours">\
    	    <select class="s_start" name="more[' + i + '][start]">' + hours() + '</select> - \
    	    <select class="s_end" name="more[' + i + '][end]">' + hours() + '</select>\
    	</td>\
    	<td class="building"><input type="text" value="" name="more[' + i + '][building]" /></td>\
    	<td class="building"><input type="text" value="" name="more[' + i + '][room]" /></td>\
    </tr>'
}

function calculate(){
	$("#avg table").each(function(){
		ects_sum = 0.0
		grade_sum = 0.0

		trs = $(this).find("tr")
		for(i=1; i<trs.length; i++){
			ects = parseInt($(trs[i]).find("td.ects input").val())
			grade = parseFloat($(trs[i]).find("td.grade input").val())
			ects_sum += ects
			grade_sum += ects * grade
		}

		console.log(grade_sum)
		console.log(ects_sum)
		avg = Math.round((grade_sum / ects_sum) * 100)/100
		$(trs[1]).find("td.avg").text(avg)
		
	})
}

function autofill_endtime(event){
    var v = ""
    if(this.value == "07:30") v = "09:00"
    else {
        var h = parseInt(this.value.substr(0, 1)) * 10 + parseInt(this.value.substr(1, 1)) 
        var m = parseInt(this.value.substr(3, 1)) * 10 + parseInt(this.value.substr(4, 1)) 
        var mm = (h*60) + m + 105
        v = format(parseInt(mm / 60)) + ":" + format(mm % 60)
    }
        
    $(this).next().val(v)
}

var pmore_i = 0
$(document).ready(function(){
	$("#avg table td.ects input").livequery("change", calculate)
	$("#avg table td.grade input").livequery("change", calculate)
	$("#avg_more").click(function(){
		div = '<div class="semester"></div>'
		table = '<table>\
					<tr>\
						<th class="name">Nazwa kursu</th>\
						<th>ECTS</th>\
						<th>Ocena</th>\
						<th>Srednia</th>\
					</tr>\
				</table>'
				
		ftr = $(tr)
		ftr.append('<td class="avg" rowspan="1">')
		ftr.find("a").addClass("f")

		$("#avg").append(
			$(div).append("<h4></h4>").append(
				$(table).append(ftr)
			).append($('<input type="button" class="add" value="Dodaj kurs"/>').click(function(){
				atr = $(tr)
				atr.find("td a").click(function(){
					$(this).parent().parent().remove()
					tdavg = $(this).parent().parent().parent().find("td.avg")
					tdavg.attr("rowspan", parseInt(tdavg.attr("rowspan"))-1)
					return false;
				})
				tdavg = $(this).parent().find("table").append(atr).find("td.avg")
				tdavg.attr("rowspan", parseInt(tdavg.attr("rowspan"))+1)
			}))
		)

		$(this).remove()
	})
	calculate()
	
	
	
	
	$("#pmore .s_start").livequery("change", autofill_endtime)
	$("#plan_more").click(function(){
		div = '<div class="semester"></div>'
		table = '<table>\
					<tr>\
						<th class="name">Nazwa kursu</th>\
						<th>Typ</th>\
						<th>Tydzień</th>\
						<th>Dzień</th>\
						<th>Godziny</th>\
						<th>Budynek</th>\
						<th>Pokój</th>\
					</tr>\
				</table>'
				
		ftr = $(ptr(0))
        ftr.find("td a").click(function(){
			$(this).parent().parent().remove()
			return false;
		})

		$("#pmore").append(
			$(div).append("<h4></h4>").append(
				$(table).append(ftr)
			).append($('<input type="button" class="add" value="Dodaj kurs"/>').click(function(){
				atr = $(ptr(++pmore_i))
				atr.find("td a").click(function(){
					$(this).parent().parent().remove()
					return false;
				})
				$(this).parent().find("table").append(atr)
			}))
		)

		$(this).remove()
	})
	
	$("#examples a").fancybox();
})