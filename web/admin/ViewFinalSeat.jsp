<%@page import="Do.*"%>
<%@page import="Domain.*"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    long trainClassStatusID = Long.parseLong(request.getParameter("classID"));
    TrainClassStatus tcs = new TrainClassStatusDO().get(trainClassStatusID);
    String mode = request.getParameter("mode");
    if (!tcs.chart && mode == null) {
        out.println("900");
        out.flush();
        return;
    }
    ChartDO chartDO = new ChartDO();
    TrainClassSeatStatusDO tcssdo = new TrainClassSeatStatusDO();
    PassengerDO pdo = new PassengerDO();
    //long trainClassStatusID = 1;
    SeatPassengerDO seatPassengerDO = new SeatPassengerDO();
    SeatTypeDO seatTypeDO = new SeatTypeDO();

    List<String> coachList = new CoachDO().getAllCoachOfTrainClassStatus(trainClassStatusID);
%>
<!-- <button class="btn btn-default" onclick="showDefault()" style="margin-right: 3%">Close this chart</button>-->
<button onclick="PrintElem(0)">Print this chart</button>
<br><br>

<div id="to_print">
    <%
        //List< TrainClassSeatStatus> allSeat = tcssdo.getAll(trainClassStatusID);
        boolean unAssign = false;
        for (String coach : coachList) {
            List< TrainClassSeatStatus> allSeat = tcssdo.getAllOfCoach(trainClassStatusID, coach);
            out.println("Coach:" + coach + "<br>");
            out.println("<table border=1 class=\"table table-bordered\"><thead><tr></tr></thead>");
            out.println("<thead><tr><th style=\"maxwidth:3%\">SeatNo</th><th>LB</th><th>MB</th><th>UB</th><th>LB</th><th>MB</th><th>UB</th><th>SU</th></tr></thead>");
            out.println("<tbody>");
            String same;
            TrainClassSeatStatus seat = null;
            long lastPnr = 0;
            int row = 1;
            for (int i = 0; i < allSeat.size();) {
                out.println("<tr><td>"+(((row-1)*8)+1)+"-"+(row*8)+"</td>");
                for (int j = 0; j < 7; j++) {
                    if (i < 63) {
                        seat = allSeat.get(i);
                    }
                    i = i + 1;
                    if (seat.availability) {
                        out.println("<td style=\"color:lightgray\">" + seat.seatNo + "<br>  " + seatTypeDO.getType(seat.typeId) + "<br>  " + "Not booked" + "<br> " + "" + "<br>" + "" + "<br>" + "" + "</td> ");
                    } else {
                        long pnr = seatPassengerDO.get(seat.trainClassSeatStatusId).pnr;
                        if (pnr == lastPnr) {
                            same = "style=\"color:blue\"";
                        } else {
                            same = "";
                        }
                        lastPnr = pnr;
                        if (pnr == 0) {
                            unAssign = true;
                            out.println("<td style=\"color:orange\" >" + seat.seatNo + "<br>  " + seatTypeDO.getType(seat.typeId) + "<br>  " + "Not assigned<span style=\"color:blue\">*</span>" + "<br> " + "" + "<br>" + "" + "<br>" + "" + "</td> ");
                        } else {
                            String gen;
                            Passenger p = pdo.getByCNFSeat(pnr, seat.seatNo);
                            if (p.gender == 1) {
                                gen = "Male";
                            } else {
                                gen = "Female";
                            }
                            out.println("<td class=\"filled\" name=\"" + pnr + "\" " + same + ">" + seat.seatNo + "<br>  " + seatTypeDO.getType(seat.typeId) + "<br>" + pnr + "<br> " + p.name + "<br>" + gen + "<br>" + p.age + "</td> ");
                        }
                    }
                }
                out.println("</tr>");
                row++;
                /*if (row == 2) {
                    out.println("</tbody></table>Coach:S2<br><table class=\"table table-bordered\"><tbody>");
                }*/
            }
            out.println("</tbody></table><br>");
        }
        
        if (unAssign) {
            out.println("<span style=\"color:blue\">*</span> Prepare chart to view the final seat assignment.");
        }
    %>
    <br>

    <%
        List<Passenger> racList = chartDO.getAllByStatus(2);

        if (racList.size()
                == 0) {
            out.println("<!--");
        }

        out.println(
                "Passengers who are in RAC and share the rac seats<br>");
        out.println(
                "<table class=\"table table-bordered\"><thead><tr><th>PNR</th><th>Name</th><th>Age</th><th>Seat</th></tr></thead>");
        out.println(
                "<tbody>");
        int finalRacCount = racList.size();
        if (finalRacCount <= ((tcs.maxRac) / 2)) {
            for (Passenger p : racList) {
                p.seat_no = (p.seat_no * 8) - 1;
                out.println("<tr><td>" + p.pnr + "</td><td> " + p.name + "</td><td>" + p.age + "</td><td>" + p.seat_no + "</tr>");
            }
        } else if (finalRacCount == tcs.maxRac) {
            int i = 0;
            boolean flg = false;
            for (Passenger p : racList) {
                String seatS = "" + ((i * 8) + 7);
                if (!flg) {
                    seatS += " A";
                    flg = true;
                } else {
                    seatS += " B";
                    flg = false;
                    i++;
                }
                out.println("<tr><td>" + p.pnr + "</td><td> " + p.name + "</td><td>" + p.age + "</td><td>" + "RAC" + p.seat_no + "</tr>");
            }
        } else {
            int singleCount = tcs.maxRac - finalRacCount, i;
            for (i = 0; i < singleCount; i++) {
                Passenger p = racList.get(0);
                p.seat_no = (p.seat_no * 8) - 1;
                out.println("<tr><td>" + p.pnr + "</td><td> " + p.name + "</td><td>" + p.age + "</td><td>" + p.seat_no + "</tr>");
                racList.remove(p);
            }
            boolean flg = false;
            for (Passenger p : racList) {
                String seatS = "" + ((i * 8) + 7);
                if (!flg) {
                    seatS += " A";
                    flg = true;
                } else {
                    seatS += " B";
                    flg = false;
                    i++;
                }
                out.println("<tr><td>" + p.pnr + "</td><td> " + p.name + "</td><td>" + p.age + "</td><td>" + "RAC" + p.seat_no + "</tr>");
            }
        }

        out.println(
                "</tbody></table>");
        if (racList.size()
                == 0) {
            out.println("-->");
        }
    %>
</div>
<script>
    // var objlist=$(".filled").css("border", "9px solid blue");
    //console.log(objlist.size());
    // function a() {
        j(".filled").each(function (index) {
        //console.log($(this).attr("name"));
        //console.log(getColor($(this).attr("name")));
    j(this).css("background-color", getColor(j(this).attr("name")));
    }); 
    var obj = j(".filled");
    var before = new Array();     for (i = 0; i < 7; i++)
    {
    }

    //}

        function getColor(pnr)
    {
        var r = "F" + pnr.substring(11, 12);
        var g = "F" + pnr.substring(9, 10);
        var b = "F" + pnr.substring(10, 11);
    return "#" + r + "" + g + "" + b;
    }
</script>