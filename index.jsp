<%@ page import="java.util.ArrayList,java.util.Random,java.net.URLEncoder,java.net.URLDecoder,java.io.File,java.nio.file.Files,com.google.gson.Gson,pl.psychoration.*" %>
<%@ page pageEncoding="UTF-8" %>
<%

String moodRequest = request.getParameter("moodRequest");
Mood requestedMood = null;
Gson gson = new Gson();
if (moodRequest != null) {
    moodRequest = URLDecoder.decode(moodRequest);
}

File db = new File("/usr/share/tomcat9/webapps/hackheroes/db/");
if (!db.exists()) {
    out.println("Baza jest pusta. Nie można poprawnie załadować strony.");
    return;
}

File[] listFiles = db.listFiles();
ArrayList<Mood> loadedMoods = new ArrayList<>();

for (int i = 0; i < listFiles.length; i++) {
    File moodFile = listFiles[i];
    try {
        Mood mood = gson.fromJson(new String(Files.readAllBytes(moodFile.toPath()), "UTF-8"), Mood.class);
        loadedMoods.add(mood);
        if (requestedMood == null && mood.mood.equalsIgnoreCase(moodRequest)) {
            requestedMood = mood;
        }
    } catch (Throwable t) {
        out.println("Wadliwy plik: " + moodFile.toPath().toString());
    }
}

%>

<html lang="pl">
    <head>
        <title>Psychoration</title>
        <meta charset="utf-8">
        <link rel="stylesheet" type="text/css" href="style.css">
        <link href="https://fonts.googleapis.com/css2?family=Cantarell&display=swap" rel="stylesheet">
        <link rel="icon" href="icon.png">
    </head>
    <body>
        <div class="introduction">
            <h2>Witaj na stronie Psychoration!<br>
            Na podstawie Twojego stanu emocjonalnego, strona odpowie Tobie czymś, co może pozytywnie wpłynąć na Twoje samopoczucie i myślenie.</h2>
        </div>
        <div class="selection">
            Wybierz z listy nastrój, który najlepiej pasuję do Twojego aktualnego stanu emocjonalnego:<br><br>
            <form action="" method="post" id="request_form"<% if (requestedMood != null) out.print(" value=" + requestedMood.mood.toLowerCase()); %>>
                <select name="moodRequest">
                    <%
                    for (Mood m : loadedMoods) {
                        String moodName = m.mood.substring(0, 1).toUpperCase() + m.mood.substring(1).toLowerCase();
                        out.println("<option value=\"" + URLEncoder.encode(m.mood.toLowerCase()) + "\"" + (requestedMood != null && requestedMood.mood.equalsIgnoreCase(moodName) ? " selected=\"true\"" : "") + ">" + moodName + "</option>");
                    }
                    %>
                </select>
            </form>
            <button type="submit" form="request_form">Losuj</button>
        </div>
        <br>
        <div class="response">
            <%
            if (requestedMood != null) {
                ArrayList<MaterialContent> list = requestedMood.content;
                Random r = new Random();
                MaterialContent content = list.get(r.nextInt(list.size()));
                String toPrint = content.html_content;
                if (content.type.equals("book")) {
                    out.println("Polecamy zainteresować się książką:<br>" + toPrint);
                } else if (content.type.equals("quotation")) {
                    out.println("<i>" + toPrint + "</i>");
                } else if (content.type.equals("poem")) {
                    out.println("Polecamy przeczytać utwór:<br>" + toPrint);
                } else if (content.type.equals("music")) {
                    out.println("Polecamy odsłuchać utwór:<br>" + toPrint);
                } else {
                    out.println(toPrint);
                }
            }
            %>
        </div>
    </body>
</html>