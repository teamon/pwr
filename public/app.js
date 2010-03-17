tr = '<tr>\
	<td class="name"><a href="#">X</a> <input type="text" value="" /></td>\
	<td class="ects"><input type="text" value="" /></td>\
	<td class="grade"><input type="text" value="" /></td>\
</tr>'

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

$(document).ready(function(){
	$("#avg table td.ects input").livequery("change", calculate)
	$("#avg table td.grade input").livequery("change", calculate)
	$(".actions input[type=button]").click(function(){
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
})