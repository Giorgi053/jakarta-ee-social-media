<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="org.example.demo.Post" %> <!-- Import Post class -->
<%@ page import="org.example.demo.DatabaseConnection" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("username") == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Get logged-in user details
    Integer userId = (Integer) userSession.getAttribute("userId");
    String username = (String) userSession.getAttribute("username");

    // Fetch profile info from the database
    String userBio = null;
    String profilePictureUrl = null;

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


    List<Post> posts = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection()) {
        String sql = """
                    SELECT p.post_id, p.post_text
                    FROM posts p
                    WHERE p.user_id = ?
                       OR p.user_id IN (SELECT followed_id FROM followers WHERE follower_id = ?)
                    ORDER BY p.created_at DESC
                """;
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                posts.add(new Post(rs.getInt("post_id"), rs.getString("post_text")));
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    request.setAttribute("posts", posts);
    session.setAttribute("userBio", userBio);
    session.setAttribute("profilePictureUrl", profilePictureUrl);

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
</head>
<body>
<h1>Welcome, <%= username %>!</h1>

<!-- Profile Section -->
<h2>Profile Info</h2>
<p><strong>Bio:</strong> <%= (userBio != null && !userBio.isEmpty()) ? userBio : "No bio available." %></p>
<img src="<%= profilePictureUrl != null ? profilePictureUrl : "default-profile.jpg" %>" alt="Profile Picture" width="100" height="100">


<!-- New Post Section -->
<h3>Create a New Post</h3>
<form action="<%= request.getContextPath() %>/createPost" method="POST">
    <textarea name="postText" placeholder="What's on your mind?" required></textarea>
    <button type="submit">Post</button>
</form>

<!-- Display Posts Section -->
<h3>Your Posts and Followed Users' Posts</h3>
<c:choose>
    <c:when test="${not empty posts}">
        <ul>
            <c:forEach var="post" items="${posts}">
                <li>
                    <c:out value="${post.postText}" /> <!-- ✅ Prevents XSS attacks -->
                    <form action="<%= request.getContextPath() %>/DeletePostServlet" method="POST" style="display:inline;">
                        <input type="hidden" name="postId" value="${post.postId}">
                        <button type="submit">Delete</button>
                    </form>
                </li>

            </c:forEach>
        </ul>
    </c:when>
    <c:otherwise>
        <p>No posts available.</p>
    </c:otherwise>
</c:choose>

<!-- Edit Profile -->
<a href="editProfile.jsp">Edit Profile</a><br>

<!-- Logout -->
<a href="logout">Logout</a>
</body>
</html>
