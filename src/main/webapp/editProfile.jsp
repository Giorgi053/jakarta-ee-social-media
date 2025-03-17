<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="org.example.demo.DatabaseConnection" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("username") == null) {
        response.sendRedirect("login.html");
        return;
    }

    Integer userId = (Integer) userSession.getAttribute("userId");
    String username = (String) userSession.getAttribute("username");
    String userBio = null;
    String profilePictureUrl = null;

    // Fetch user profile info from the database
    try (Connection conn = DatabaseConnection.getConnection()) {
        String profileQuery = "SELECT bio, profile_picture_url FROM user_profiles WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(profileQuery)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                userBio = rs.getString("bio");
                profilePictureUrl = rs.getString("profile_picture_url");
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile</title>
</head>
<body>
<h1>Edit Profile</h1>

<form action="<%= request.getContextPath() %>/UpdateProfileServlet" method="POST">
    <label for="bio">Bio:</label><br>
    <textarea id="bio" name="bio" rows="4" cols="50"><%= userBio != null ? userBio : "" %></textarea><br>

    <label for="profilePictureUrl">Profile Picture URL:</label><br>
    <input type="text" id="profilePictureUrl" name="profilePictureUrl" value="<%= profilePictureUrl != null ? profilePictureUrl : "" %>"><br><br>

    <button type="submit">Save Changes</button>
</form>

<br>
<a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>
