using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json;
using System.Text.Json.Nodes;

public partial class Program : Node
{
	/*
		 * Suits: clubs (♣), diamonds (♦), hearts (♥) and spades (♠).
		 * Cards are represented like this: [Value as String, Suit as String],
		 * For example: ["3", "Diamond"], ["12", "Heart"]
		 * 
		 * NOTE: special values: 11 - Joker, 12 - Queen, 13 - King, 14 - Ace
		 */
		public string[] WinnerNames { get; set; } 
		public List<ApplicationUser> users = new List<ApplicationUser>();
		static List<string[]> CardsFromGodot = new List<string[]>();
		public List<int> UserBets { get; set; }
		
		public void AssignStringArray(string[] arr)
		{
			CardsFromGodot.Add(arr);
		}
		public void Clear()
		{
			CardsFromGodot.Clear();
			users.Clear();
			UserBets.Clear();
		}
		public void GetDataFromJSON(string json)
		{
			UserBets = new List<int>();
			JsonNode root = JsonNode.Parse(json);
			foreach (var kvp in root.AsObject())
			{
				string key = kvp.Key;
				JsonArray data = kvp.Value.AsArray();
				
				int chips = data[0].GetValue<int>();
				int bets = data[1].GetValue<int>();
				UserBets.Add(bets);
				JsonArray cards = data[2].AsArray();
				JsonArray values = data[3].AsArray();
				
				List<string[]> card_values = new List<string[]>();
				
				//GD.Print("Values:");
				foreach (JsonArray pair in values)
				{
					string number = pair[0].ToString();
					string suit = pair[1].ToString();
					string[] card_value = new string [] { number, suit };
					card_values.Add(card_value);
				}
				//GD.Print(key);
				ApplicationUser user = new ApplicationUser
				{
					Name = key,
					PlayerCards = card_values,
					Chips = chips
				};
				//GD.Print(user);
				users.Add(user);
			}
			foreach (int i in UserBets)
			{
				GD.Print(i);
			}
		}
		public void TestProgram()
		{
			List<string> WinnersList = new List<string>();
			GD.Print("Table cards:");
			foreach (string[] o in CardsFromGodot)
			{
				GD.Print(o);
			}
			GD.Print(" Table cards END \n");
			Room room = new Room
			{
				RoomName = "Test Room",
				CardsOnTable = new List<string[]>(CardsFromGodot)
			};
			switch(users.Count()) 
			{
				case 2:
					room.Chair0 = users[0];
					room.Chair1 = users[1];
					room.PotOfChair0 = UserBets[0];
					room.PotOfChair1 = UserBets[1];
					break;
				case 3: 
					room.Chair0 = users[0];
					room.Chair1 = users[1];
					room.Chair2 = users[2];
					room.PotOfChair0 = UserBets[0];
					room.PotOfChair1 = UserBets[1];
					room.PotOfChair2 = UserBets[2];
					break;
				case 4:
					room.Chair0 = users[0];
					room.Chair1 = users[1];
					room.Chair2 = users[2];
					room.Chair3 = users[3];
					room.PotOfChair0 = UserBets[0];
					room.PotOfChair1 = UserBets[1];
					room.PotOfChair2 = UserBets[2];
					room.PotOfChair3 = UserBets[3];
					break;
				case 5:
					room.Chair0 = users[0];
					room.Chair1 = users[1];
					room.Chair2 = users[2];
					room.Chair3 = users[3];
					room.Chair4 = users[4];
					room.PotOfChair0 = UserBets[0];
					room.PotOfChair1 = UserBets[1];
					room.PotOfChair2 = UserBets[2];
					room.PotOfChair3 = UserBets[3];
					room.PotOfChair4 = UserBets[4];
					break;
				case 6:
					room.Chair0 = users[0];
					room.Chair1 = users[1];
					room.Chair2 = users[2];
					room.Chair3 = users[3];
					room.Chair4 = users[4];
					room.Chair5 = users[5];
					room.PotOfChair0 = UserBets[0];
					room.PotOfChair1 = UserBets[1];
					room.PotOfChair2 = UserBets[2];
					room.PotOfChair3 = UserBets[3];
					room.PotOfChair4 = UserBets[4];
					room.PotOfChair5 = UserBets[5];
					break;
			}
				

			//room.PotOfChair0 = 25;
			//room.PotOfChair2 = 50;
			//room.PotOfChair3 = 100;
			//room.PotOfChair4 = 100;
			
			var result = room.SpreadMoneyToWinners();
			GD.Print("Winners");
			int i = 0;
			//foreach (var res in result)
			//{
				foreach (var user in result[0].Winners)
				{
					WinnersList.Add(user.Name);
					GD.Print(user.Name);
				}
				i++;
			//}
				WinnerNames = WinnersList.ToArray();
				GD.Print(result[0].RankName);
				GD.Print(result[0].PotAmount);
				GD.Print(result[0].OriginalPotAmount);
			GD.Print("Winner End");
		}
}
