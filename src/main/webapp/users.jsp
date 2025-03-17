<%@ page import="java.util.List" %>
<%
    List<String> users = (List<String>) request.getAttribute("users");
%>
<h2>User List</h2>
<% if (users != null && !users.isEmpty()) { %>
<ul>
    <% for (String user : users) { %>
    <li><%= user %></li>
    <% } %>
</ul>
<% } else { %>
<p>No users found.</p>
<% } %>
