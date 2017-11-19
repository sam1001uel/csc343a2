import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {
	
	Connection conn;
	
    public Assignment2() throws ClassNotFoundException {
    	
    		Class.forName("org.postgresql.Driver");
           
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
    		try {
            conn = DriverManager.getConnection(url, username, password);
            System.out.println("connected!");
            
            String search_path = "set search_path to parlgov";
    			PreparedStatement ps = conn.prepareStatement(search_path);
    			ps.executeUpdate();
    		
            return true;
    		}
    		catch (SQLException se) {
    			System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
    			return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
    		try {
    			conn.close();
    			System.out.println("disconnected!");
    			return true;
    		}
    		catch (SQLException se) {
    			System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
    			return false;
        }      
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
    		ElectionCabinetResult result = new ElectionCabinetResult(new ArrayList<Integer>(), new ArrayList<Integer>());    		
    		try {
    			//Drop existing views
    			PreparedStatement dropView_ps = conn.prepareStatement("drop view if exists all_elections cascade");
    			dropView_ps.execute();
    			
    			//get countryId according to countryName    			
    			//Prepare Statement
        		String getcountryId_query = "select id from country where name = ?"; 
        		PreparedStatement getcountryId_ps = conn.prepareStatement(getcountryId_query);
        		getcountryId_ps.setString(1, countryName);
        		
        		//Execute getcountryId query
        		ResultSet getcountryId_rs = getcountryId_ps.executeQuery();
        		while(getcountryId_rs.next()) {
        			int countryId = getcountryId_rs.getInt("id"); 
        			
        			//Prepare Statement
        			String createView_query = 
        					"create view all_elections as "+
        					"select id as election_id, e_date as date , e_type "+
        					"from election "+
        					"where country_id = "+ Integer.toString(countryId) + " " + 
        					"order by e_date desc";
        			
        			
        			PreparedStatement createView_ps = conn.prepareStatement(createView_query);        		
        			//Execute create View all_elections query
        			createView_ps.execute();
        			System.out.println("View all_elections created!");
        			
        			//Prepare Statement
        			String answer_query = 
        					"select all_elections.election_id, cabinet.id as cabinet_id, date, cabinet.start_date as cabinet_date "+
        					"from all_elections join cabinet on all_elections.election_id=cabinet.election_id "+
        					"order by date desc, cabinet_date desc ";
        					
        			PreparedStatement answer_ps = conn.prepareStatement(answer_query);
        			//Execute Answer query
        			ResultSet answer_rs = answer_ps.executeQuery();
        			while (answer_rs.next()) {
        				int electionId = answer_rs.getInt("election_id");
        				int cabinetId = answer_rs.getInt("cabinet_id");
        				result.elections.add(electionId);
        				result.cabinets.add(cabinetId);
        				        			
        			}    				
        		}        		    			        			        	    
            return result;
    		}
    		catch (SQLException se) {
    			System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
    			return result;
        }     
    		
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianId, Float threshold) {
        // Implement this method!
    		List<Integer> result = new ArrayList<Integer>();
    		try {
    			//Get the comment and description of the given politicianId
        		String givenPolitician_query = "select description, comment from politician_president where id = ?";
        		PreparedStatement givenPolitician_ps = conn.prepareStatement(givenPolitician_query);    
        		givenPolitician_ps.setInt(1, politicianId);
        		
        		//Execute get comment and description of given politician query
        		ResultSet givenPolitician_rs = givenPolitician_ps.executeQuery();
        		givenPolitician_rs.next();
        		String givenP_description = givenPolitician_rs.getString("description");
        		String givenP_comment = givenPolitician_rs.getString("comment");
        		String givenP_string = givenP_description + " " + givenP_comment;
        		
        		System.out.println(givenP_string);
        		
            return result;
    		}
    		catch (SQLException se) {
    			System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
    			return result;
        }   
    }

    public static void main(String[] args) {
    		try {
    			Assignment2 test = new Assignment2();
        		String url = "jdbc:postgresql://localhost:5432/csc343h-leetsz9";
        		
        		//test q1
        		boolean test_connected = test.connectDB(url, "leetsz9", "");
        		
        		//test q3
        		//ElectionCabinetResult test_q3_Canada = test.electionSequence("Canada");
        		//ElectionCabinetResult test_q3_Germany = test.electionSequence("Germany");
        		//ElectionCabinetResult test_q3_wrongname = test.electionSequence("Franc");
        		
        		//System.out.println(test_q3_Canada);
        		//System.out.println(test_q3_Germany);      		
        		//System.out.println(test_q3_wrongname);
        		
        		//test q4
        		List<Integer> test_q4 = test.findSimilarPoliticians(148, (float)0.3);
        		
        		//test q2
        		boolean test_disconnected = test.disconnectDB();
        		
    		}
    		catch (ClassNotFoundException e) {
        		System.out.println("Failed to find the JDBC driver");
        }
    		
    }

}

