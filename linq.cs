
//Linq Joins
// query expression 

var query = from car in cars 
join manufacturer in manufacturers
	on new {car.Manufacturer, car.Year}
		equals
		new {Manufacturer = manufacturer.Name, manufacturer.Year}
		orderby car.Combined descending, car.Name ascending

		select new {

			manufacturer.Headquarters,
			car.Name,
			car.Combined
		}
// Method Syntax

var query = cars.Join(manufactures,
			c=> new {c.manufaturer, C.Year},
			m=> new {Manafacturer = m.Name, m.Year}
			(c, m) => new {
				m.Headquarters,
				c.Name,
				c.Combined
			})
			.OrderByDescending(c => c.Combined)
			.ThenBy(c=>c.Name);

//Grouping 
//Query expression
var query = from car in cars 
group car by car.Manafacturer  into m 
orderby m.Key
select m;

foreach(var group in query){
	// Console.WriteLine(group.Key, group.Count()
		foreach(var car in group.OrderByDescending(c=> c.Combined).Take()){
			// will give first two grou items based on where clause
		}	
}

//extesion method
var query2 = cars.GroupBy(c=> c.Manafacturer)
				.OrderBy(g.Key)


//Group Join
//query expression

var query = from manafacturer in manafacturers
			join car in cars on manafacturer.Name equals car.Manafacturer
			into cargroup
			orderby manafacturer.Name
			select new  {
				Manufacturer = manufacturer,
				Cars =cargroup

			}

//extesion menthod

var query2 = manufactures.GroupJoin(cars, 
							c=> cars.Manafacturer, 
							m=> m.Name,
							(m,g) => 
							select new {
								Manufacturer = m;
								cars = g
							})
							.OrderBy(m=>m.Manufacturer.Name)


//SelectMany

var result= cars.Select(c=> C.Name)

foreach(var name in result) {
	foreach(char chr in name) {
		//character
	}

}

//equavalent to 

var result = cars.SelectMany(c=> c.Name)

foreach(char chr in result) {
		//character
	}


//Aggregation
//query expression

1var query = 
		from car in CarStatisticsgroup car by car.Manafacturer into cargroup
				select new {
					
					Name= cargroup.Key,
					Max = cargroup.Max(c=> Combined)
					Min = cargroup.Min(c=> Combined)
					Avg = cargroup.Average(c=> Combined)
				}
// Aggregation using etension methods

var query2 = cars.GroupBy(c => C.Manafacturer)
			.Select(g => {

				var result = g.Aggregate(new CarStatistics(),
									(acc, c) => acc.Accumulate(c), 
									(acc) => acc.Compute()
					);
					return new {
						Name = g.Key,
						Avg= results.Average,
						Min = results.Min,
						Max = results.Max
					};
					})
			.OrderByDescending(r.Max)

				


public class CarStatistics
    {
        public CarStatistics()
        {
            Max = Int32.MinValue;
            Min = Int32.MaxValue;
        }
        
        public CarStatistics Accumulate(Car car)
        {
            Count += 1;
            Total += car.Combined;
            Max = Math.Max(Max, car.Combined);
            Min = Math.Min(Min, car.Combined);
            return this;
        }

        public CarStatistics Compute()
        {
            Average = Total / Count;
            return this;
        }

        public int Max { get; set; }
        public int Min { get; set; }
        public int Total { get; set; }
        public int Count { get; set; }
        public double Average { get; set; }

    }



    // lelft join/ left outer join
    var q=(from pd in dataContext.tblProducts 
	 join od in dataContext.tblOrders on pd.ProductID equals od.ProductID 
	 into t from rt in t.DefaultIfEmpty() 
	 orderby pd.ProductID 
	 select new { 
	 //To handle null values do type casting as int?(NULL int) 
	 //since OrderID is defined NOT NULL in tblOrders
	 OrderID=(int?)rt.OrderID,
	 pd.ProductID,
	 pd.Name,
	 pd.UnitPrice,
	 //no need to check for null since it is defined NULL in database
	 rt.Quantity,
	 rt.Price,
	 }).ToList();


    // EF Fucntions

     var samurais = context.Samurais.Where(s => EF.Functions.Like(s.Name, "J%")).ToList();
// Must specify orderby when using LastOrDefault
     var samurais = context.Samurais.Where(s => EF.Functions.Like(s.Name, "J%"))OrderBy(s=> s.Name).LastOrDefault();


     //ForEach
     samurais.ForEach(s=> s.Name += "new");


// Map Stored Procedure to DBContext
     public async Task<List<SpGetProductByID>> GetProductByIDAsync(int productId)  
        {  
            // Initialization.  
            List<SpGetProductByID> lst = new List<SpGetProductByID>();  
  
            try  
            {  
                // Settings.  
                SqlParameter usernameParam = new SqlParameter("@product_ID", productId.ToString() ?? (object)DBNull.Value);  
  
                // Processing.  
                string sqlQuery = "EXEC [dbo].[GetProductByID] " +  
                                    "@product_ID";  
  
                lst = await this.Query<SpGetProductByID>().FromSql(sqlQuery, usernameParam).ToListAsync();  
            }  
            catch (Exception ex)  
            {  
                throw ex;  
            }  
  
            // Info.  
            return lst;  
        }  
//OR execute directly from context

context.Database.ExecuteSqlCommand("exec sp_name {0}", param1)

