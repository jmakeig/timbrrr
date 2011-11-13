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

jQuery.fn.dataTableExt.oSort['numeric-comma-asc']  = function(aa,bb) {
  // This is ugly and probably pretty inefficient
  var a = $(aa).text()
  var b = $(bb).text()
  var x = (a == "-") ? 0 : a.replace( /,/, "" );
  var y = (b == "-") ? 0 : b.replace( /,/, "" );
  x = parseFloat( x );
  y = parseFloat( y );
  console.dir([x,y]);
  return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};
jQuery.fn.dataTableExt.oSort['numeric-comma-desc'] = function(aa,bb) {
  // Why doesn't the following work?
  //-(jQuery.fn.dataTableExt.oSort['numeric-comma-asc'].call(this, aa, bb));
  var a = $(aa).text()
  var b = $(bb).text()
  var x = (a == "-") ? 0 : a.replace( /,/, "" );
  var y = (b == "-") ? 0 : b.replace( /,/, "" );
  x = parseFloat( x );
  y = parseFloat( y );
  return ((x < y) ? 1 : ((x > y) ?  -1 : 0));
};

jQuery.fn.dataTableExt.oSort['user-agent-asc']  = function(aa,bb) {
  var objs = [$(aa), $(bb)];
  var data = [
    {"ua": objs[0].data("ua"), "v": objs[0].data("v")},
    {"ua": objs[1].data("ua"), "v": objs[1].data("v")}
  ];
  if(data[0].ua === data[1].ua) {
    var v0 = parseInt(data[0].v);
    var v1 = parseInt(data[1].v);
    return (v0 < v1) ? -1 : ((v0 > v1) ?  1 : 0)
  } 
  return (data[0].ua < data[1].ua) ? -1 : (data[0].ua > data[1].ua ? 1 : 0)
};
jQuery.fn.dataTableExt.oSort['user-agent-desc']  = function(aa,bb) {
  var objs = [$(aa), $(bb)];
  var data = [
    {"ua": objs[0].data("ua"), "v": objs[0].data("v")},
    {"ua": objs[1].data("ua"), "v": objs[1].data("v")}
  ];
  if(data[0].ua === data[1].ua) {
    var v0 = parseInt(data[0].v);
    var v1 = parseInt(data[1].v);
    return (v0 < v1) ? 1 : ((v0 > v1) ?  -1 : 0)
  } 
  return (data[0].ua < data[1].ua) ? 1 : (data[0].ua > data[1].ua ? -1 : 0)
};

jQuery.fn.dataTableExt.oSort['trend-asc']  = function(aa,bb) {
  console.dir(arguments);
};

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
      var dir = $tr.find("td.direction div")[0]
        dir.className = direction;
        dir.title = slope;
        $(dir).data("slope", slope);
      renderChart(data, id);
    });
    
  });
  
  $("#UserAgents").dataTable({
    "bPaginate": false,
    "bLengthChange": false,
    "bFilter": false,
    "bSort": true,
    "bInfo": false,
    "bAutoWidth": false,
    "aoColumns": [
      null,
      {"sType": "user-agent"},
      null, // TODO: Can't seem to get trend sorting to work. Probably because of the colspan in the header.
      null,
      {"sType": "numeric-comma"}
    ]
  });
  
});
