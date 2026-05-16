$(document).ready(renderStreamgraph);
$(window).resize(renderStreamgraph);

function formatDate(date) {
    const yyyy = date.getFullYear();
    let mm = date.getMonth() + 1;
    let dd = date.getDate();

    if (dd < 10) dd = '0' + dd;
    if (mm < 10) mm = '0' + mm;

    return dd + '-' + mm + '-' + yyyy;
}

function convertDataToStream(dataRaw) {
    const data = [];
    const keys = [];
    dataRaw.forEach((itemRaw) => {
        const item = {};
        const date = new Date();
        const year = parseInt(itemRaw.ranking_date.substring(0, 4));
        const month = parseInt(itemRaw.ranking_date.substring(5, 7)) - 1;
        const day = parseInt(itemRaw.ranking_date.substring(8, 10));
        date.setFullYear(year, month, day);
        item.rankingDate = date;
        itemRaw.rankings.forEach((r) => {
            const key = r.player_name;
            if (!keys.includes(key)) {
                keys.push(key);
            }
            item[key] = r.player_points_normalized;
        })
        data.push(item);
    });
    data.forEach((item) => {
        keys.forEach((key) => {
            if (!item[key]) {
                item[key] = 0;
            }
        })
    });
    return { data, keys };
}

function renderStreamgraph() {
    const divStreamGraph = "#rankings_streamgraph";
    $(divStreamGraph).html('');
    // set the dimensions and margins of the graph
    const margin = {top: 30, right: 10, bottom: 40, left: 10},
        width = $(divStreamGraph).width() - margin.left - margin.right,
        height = $(divStreamGraph).height() - margin.top - margin.bottom;

    // append the svg object to the body of the page
    const svg = d3.select(divStreamGraph)
        .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform",
            `translate(${margin.left}, ${margin.top})`);

    // Parse the Data
    d3.json('/backhand.querytechnology.net/data/rankings/rankings.json').then((dataRaw) => {
        const { data, keys } = convertDataToStream(dataRaw);

        // Add X axis
        const x = d3.scaleTime()
            .domain(d3.extent(data, function(d) { return d.rankingDate; }))
            .range([0, width]);
        svg.append("g")
            .attr("transform", `translate(0, ${height})`)
            .call(
                d3.axisBottom(x).ticks(10)
            )
            .select(".domain").remove()
        // Customization
        svg.selectAll(".tick line").attr("stroke", "#b8b8b8")

        // Add Y axis
        const y = d3.scaleLinear()
            .domain([0, 1])
            .range([0, height]);

        // color palette
        const color = d3.scaleOrdinal()
            .domain(keys)
            .range(d3.schemeTableau10 );

        //stack the data?
        const stackedData = d3.stack()
            .offset(d3.stackOffsetExpand)
            .keys(keys)
            (data)

        // create a tooltip
        const Tooltip = svg
            .append("text")
            .attr("x", 0)
            .attr("y", -10)
            .style("opacity", 0)
            .style("font-size", 17)

        // Three function that change the tooltip when user hover / move / leave a cell
        const mouseover = function(event,d) {
            Tooltip.style("opacity", 1)
            d3.selectAll(".myArea").style("opacity", .2)
            d3.select(this)
            .style("stroke", "black")
            .style("opacity", 1)
        }
        const mousemove = function(event,d,i) {
            grp = d.key;
            date = x.invert(event.pageX - margin.left);
            Tooltip.text(`${grp} - ${formatDate(date)}`)
        }
        const mouseleave = function(event,d) {
            Tooltip.style("opacity", 0)
            d3.selectAll(".myArea").style("opacity", 1).style("stroke", "none")
        }

        // Area generator
        const area = d3.area()
            .x(function(d) { return x(d.data.rankingDate); })
            .y0(function(d) { return y(d[0]); })
            .y1(function(d) { return y(d[1]); })

        // Show the areas
        svg
            .selectAll("mylayers")
            .data(stackedData)
            .join("path")
            .attr("class", "myArea")
            .style("fill", function(d) { return color(d.key); })
            .attr("d", area)
            .on("mouseover", mouseover)
            .on("mousemove", mousemove)
            .on("mouseleave", mouseleave);
    });
}
