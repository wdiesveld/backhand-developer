var chart1 = null;
var minC = 100;
var maxC = 0;
var minV = 100;
var maxV = 0;

function loadData(uri, callback)
{
    $.getJSON(
        '/backhand.querytechnology.net/data/'+ uri + '.json',
        callback
    );
}

function convertToBubbleData2(players)
{
    data = [];
    for (var i in players) {
        var x = players[i].pressureRatingPro
        var y = players[i].sourceCorrServe;
        var v = players[i].titles;
        var c = players[i].stats.avgAcesPerMatch;
        data.push({
            x: x,
            y: y,
            v: v,
            c: c,
            playerName: players[i].playerName
        });
        minC = Math.min(minC, c);
        maxC = Math.max(maxC, c);
        minV = Math.min(minV, v);
        maxV = Math.max(maxV, v);
    }
    return {
        datasets: [{
            data: data
        }]
    };
}

function colorize01(opaque, context) {
    var value = context.dataset.data[context.dataIndex];
    var ratio = (value.c - minC) / (maxC - minC);
    var r = 128 + Math.round(127*ratio);
    var g = 128 - Math.round(127*ratio);
    var b = 128 + Math.round(64*ratio);
    var a = opaque ? 0.7 : 0.4;

    return 'rgba(' + r + ',' + g + ',' + b + ',' + a + ')';
}

window.onload = function() {
    initPressureRatingProDemo()
};

function refreshChart(players)
{
    var options = {
        aspectRatio: 1,
        legend: false,
        tooltips: {
            callbacks: {
               label: function(t, d) {
                   var bubble = d.datasets[t.datasetIndex].data[t.index];
                   return bubble.playerName;
               }
            }
        },
        scales: {
            xAxes: [{
                display: true,
                scaleLabel: {
                    display: true,
                    labelString: 'BD Under Pressure Rating'
                }
            }],
            yAxes: [{
                display: true,
                scaleLabel: {
                    display: true,
                    labelString: 'Source Correlating With #Aces'
                }
            }]
        },
        elements: {
            point: {
                backgroundColor: colorize01.bind(null, false),
                borderColor: colorize01.bind(null, true),
                borderWidth: function(context) {
                    return 2;
                },
                hoverBorderWidth: function(context) {
                    return 3;
                },
                radius: function(context) {
                    var value = context.dataset.data[context.dataIndex];
                    var size = context.chart.width;
                    var ratio = (value.v - minV) / (maxV - minV);
                    return 1 + ratio * 20 * (size / 1000);
                }
            }
        }
    };
    if (chart1) {
        chart1.data = convertToBubbleData2(players);
        chart1.update();
    } else {
        chart1 = new Chart('chart-pressure-rating', {
            type: 'bubble',
            data: convertToBubbleData2(players),
            options: options
        });
    }
}

function refreshTable(data)
{
    var div = $(".pressure-rating-pro-demo");
    div.find('table tbody').html('');
    r = 1;
    for (i in data) {
        if (r < data[i].stats.rankPressureRating) {
            move = data[i].stats.rankPressureRating - r;
            moveClass = 'move-up';
        } else if (r > data[i].stats.rankPressureRating) {
            move = r - data[i].stats.rankPressureRating;
            moveClass = 'move-down';
        } else {
            move = '-';
            moveClass = '';
        }
        div.find('table tbody').append(
            '<tr>'
            + '<td>' + r + '</td>'
            + '<td class="' + moveClass + '">' + move + '</td>'
            + '<td>' + data[i].playerName + '</td>'
            + '<td>' + data[i].stats.pressureRating + '</td>'
            + '<td>' + (Math.round(data[i].pressureRatingPro*100)/100) + '</td>'
            + '</tr>'
        );
        r++;
    }
}

function loadPressureData(set, callback)
{
    loadData('pressure/rating-pro-' + set, callback)
}

function initPressureRatingProDemo()
{
    var periodSelectors = $('.period-selection')
    periodSelectors.append('<option value="career">All Time Pressure Ranking</option');
    for (var year=2020;year>=1991;year--) {
        periodSelectors.append(`<option value="${year}">${year}</option`);
    }

    loadPressureData('career', function (data) {
        refreshChart(data);
        refreshTable(data);
    });

    $('#select-for-chart').change(function () {
        loadPressureData($(this).val(), refreshChart)
    });

    $('#select-for-table').change(function () {
        loadPressureData($(this).val(), refreshTable)
    });
}