$(window).load(function () {

	$('.node').on('click', function() {
		console.log("YER A WINNER");
	})

	//Stuff for tooltip

	var tooltip = d3.selectAll(".tooltip:not(.css)");
	var HTMLmouseTip = d3.select("div.tooltip.mouse");

	d3.select("svg").selectAll('.node')
		.attr("title", "Automatic Title Tooltip")

		.on("mouseover", function() {
			tooltip.style("opacity", "1");
		

		 	tooltip.style("color", this.getAttribute("fill") );

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



