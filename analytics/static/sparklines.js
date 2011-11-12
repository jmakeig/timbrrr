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
  $("#UserAgents tr").each(function() {
    var ua = $(this).data("ua");
    var v = $(this).data("v");
    var id = $(this).find(".sparkline")[0].id;
    $.getJSON("user-agent-weeks.xqy?ua="+ua+"&v=" + v, function(data) {
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
