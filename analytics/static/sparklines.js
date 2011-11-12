function renderChart(data, container) {
  new Highcharts.Chart({
      chart: {
          renderTo: container,
          defaultSeriesType: 'area',
          margin:[0,0,0,0],
      },
      title:{
          text:''
      },
      credits:{
          enabled:false
      },
      xAxis: {
          labels: {
              enabled:false
          }
      },
      yAxis: {
          maxPadding:0,
          minPadding:0,
          endOnTick:false,
          labels: {
              enabled:false
          }
      },
      legend: {
          enabled:false
      },
      tooltip: {
          enabled:false
      },
      plotOptions: {
          series:{
              lineWidth:1,
              shadow:false,
              states:{
                  hover:{
                      lineWidth:1
                  }
              },
              marker:{
                  enabled:false,
                  radius:1,
                  states:{
                      hover:{
                          radius:2
                      }
                  }
              }
          }
      },
      series: [{
          animation: false,
          color:'#666',
          fillColor:'rgba(204,204,204,.25)',
          data: data
          
      }]
  });
}

$(document).ready(function() {
  $("#UserAgents tbody tr").each(function() {
    var $tr = $(this);
    var ua = $tr.data("ua");
    var v = $tr.data("v");
    var id = $tr.find(".sparkline")[0].id;
    $.getJSON("user-agent-weeks.xqy?ua="+ua+"&v=" + v, function(data) {
      /* Should only have to do this once */
      var x = [];
      for(var i = 0; i < data.length; i++) {
        x[i] = i + 1;
      }
      // Fit a line to the most recent 25 points
      var ls = leastSquares(x.slice(data.length - 25, data.length - 1), data.slice(data.length - 25, data.length - 1));
      // Calculate the slope of the line
      var slope = (ls[1][1] - ls[1][0]) / (ls[0][1] - ls[0][0]);
      // Update the display of the slope direction
      var direction = "flat";
      if(slope > 0.1) direction = "upward";
      if(slope < -0.1) direction = "downward";
      $tr.find("td.direction div")[0].className = direction;
      renderChart(data, id);
    });
  });
/*
  $.getJSON("user-agent-weeks.xqy?ua=Firefox&v=8", function(data) {
    renderChart(data, "Firefox_8");
  });
  $.getJSON("user-agent-weeks.xqy?ua=Internet+Explorer&v=9", function(data) {
    renderChart(data, "IE_9");
  }); 
  $.getJSON("user-agent-weeks.xqy?ua=Chrome&v=14", function(data) {
    renderChart(data, "Chrome_14");
  });  
*/
});
