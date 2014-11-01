$(window).load(function () {

	//Gets rid of title tooltips on the node that we don't want
	$('[title]').removeAttr('title');
	
	$('.node').on('click', function() {
		console.log("YER A WINNER");
	})

	//Stuff for tooltip

	var tooltip = d3.selectAll(".tooltip:not(.css)");
	var HTMLmouseTip = d3.select("div.tooltip.mouse");

	d3.select("svg").selectAll('.node')

		.on("mouseover", function() {
			var title = $(this).children().first().text();
			var data = $('.' + title).text();
			console.log(data);
			tooltip.style("opacity", "1");
		 	tooltip.style("color", this.getAttribute("fill"));
		 	tooltip.html(data);

	        var matrix = this.getScreenCTM()
	                .translate(+this.getAttribute("cx"),
	                         +this.getAttribute("cy"));

    		 HTMLmouseTip
    	            .style("left", Math.max(0, d3.event.pageX - 150) + "px")
    	            .style("top", (d3.event.pageY + 20) + "px");
		})

	    .on("mouseout", function () {
	        return tooltip.style("opacity", "0");
	    });

});



