#include <iostream>
#include <vector>
#include <dae.h>
#include <dom/domCOLLADA.h>

#import <Foundation/Foundation.h>

#define EPSILON 0.0001


daeElement* root;
daeDatabase *db;


using namespace std;

void _write(NSMutableDictionary * propertyList, NSString * file){
	
	 NSData *dataRep;
	 NSString *errorStr = nil;
	 //NSDictionary *propertyList;
	 
	 //propertyList = [NSDictionary dictionaryWithObjectsAndKeys:
	 //              @"Javier", @"FirstNameKey",
	 //            @"Alegria", @"LastNameKey", nil];
	 dataRep = [NSPropertyListSerialization dataFromPropertyList: propertyList
	 format: NSPropertyListXMLFormat_v1_0
	 errorDescription: &errorStr];
	 if (!dataRep) {
	 // Handle error
	 }	
	 
	 [dataRep writeToFile:file atomically:NO];	 
}

int f_equal(float a, float b){
	return fabs(a-b) < EPSILON;
}

daeTArray<double> & get_float_array(vector<domGeometry*> & geoms, int n){
	//string a;
	daeElement* elt0 = geoms[0]->getChild("mesh");
	//a = elt0->getElementName();
	//cout << a;
	daeTArray<daeElementRef> children = elt0->getChildren();
	daeElement* elt00 = children[n];
	//a = elt00->getElementName();
	//cout << a;
	daeTArray<daeElementRef> children1 = elt00->getChildren();
	daeElement* elt000 = children1[0];	
	//a = elt000->getElementName();
	//cout << a;
	
	//string s1(geoms[0]->getId());
	//s1 += "-map-0-array";
	//daeElement* elt1 = db->idLookup(s1.c_str(), root->getDocument());
	domFloat_array * tex = (domFloat_array *)elt000;
	daeTArray<double> & _tex = tex->getValue();	
	
	return _tex;
}

void get_material(domEffect * e, NSMutableDictionary * m){
	daeElement * A = e->getDescendant("diffuse");
	daeElement * B = A->getChild("texture");
	if (B != NULL) {
		[m setObject:@"texture" forKey:@"type"];
		daeElement * C = e->getDescendant("init_from");
		string D = C->getCharData();
		daeElement* E = db->idLookup(D.c_str(), root->getDocument());
		daeElement * F = E->getChild("init_from");
		string G = F->getCharData();
		[m setObject:[NSString stringWithFormat:@"%s", G.c_str()] forKey:@"file"];
	} else {
		B = A->getChild("color");
		string C = B->getCharData();
		NSArray *D = [[NSString stringWithFormat:@"%s", C.c_str()] componentsSeparatedByString: @" "];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:0] floatValue]] forKey:@"diffuse_r"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:1] floatValue]] forKey:@"diffuse_g"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:2] floatValue]] forKey:@"diffuse_b"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:3] floatValue]] forKey:@"diffuse_a"];
		
		daeElement * A = e->getDescendant("ambient");
		B = A->getChild("color");
		C = B->getCharData();
		D = [[NSString stringWithFormat:@"%s", C.c_str()] componentsSeparatedByString: @" "];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:0] floatValue]] forKey:@"ambient_r"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:1] floatValue]] forKey:@"ambient_g"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:2] floatValue]] forKey:@"ambient_b"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:3] floatValue]] forKey:@"ambient_a"];
		
		A = e->getDescendant("reflective");
		B = A->getChild("color");
		C = B->getCharData();
		D = [[NSString stringWithFormat:@"%s", C.c_str()] componentsSeparatedByString: @" "];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:0] floatValue]] forKey:@"specular_r"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:1] floatValue]] forKey:@"specular_g"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:2] floatValue]] forKey:@"specular_b"];
		[m setObject:[NSNumber numberWithFloat:[(NSString *)[D objectAtIndex:3] floatValue]] forKey:@"specular_a"];
		
		A = e->getDescendant("shininess");
		if (A != NULL) {
			B = A->getChild("float");
			C = B->getCharData();
			D = [NSString stringWithFormat:@"%s", C.c_str()];
			[m setObject:(NSString *)[D objectAtIndex:0] forKey:@"shininess"];
		}
	}

}



int main (int argc, char * const argv[]) {
	id pool=[NSAutoreleasePool new];
	
	//DAE * dae = new DAE;
	DAE dae;
	
	root = dae.open("untitled.dae");
	if (!root) {
		cout << "Document import failed.\n";
		return 0;
	}	
	
	db = dae.getDatabase();
	vector<domGeometry*> geoms = db->typeLookup<domGeometry>();
	//for (size_t i = 0; i < geoms.size(); i++)
	//	cout << "geom " << i << " id: " << geoms[i]->getId() << endl;
	
	//old pos
	/*string s(geoms[0]->getId());
	s += "-positions-array";
	daeElement* elt = db->idLookup(s.c_str(), root->getDocument());
	domFloat_array * pos = (domFloat_array *)elt;
	daeTArray<double> & _pos = pos->getValue();*/
	daeTArray<double> & _pos = get_float_array(geoms, 0);
	int cou = _pos.getCount();
	
	//old nor
	/*string s2(geoms[0]->getId());
	s2 += "-normals-array";
	daeElement* elt2 = db->idLookup(s2.c_str(), root->getDocument());
	domFloat_array * nor = (domFloat_array *)elt2;
	daeTArray<double> & _nor = nor->getValue();*/
	daeTArray<double> & _nor = get_float_array(geoms, 1);
	cou = _nor.getCount();
	
	//old tex
	daeTArray<double> & _tex = get_float_array(geoms, 2);	

	//new pos
	NSMutableArray * newpos = [NSMutableArray arrayWithCapacity:_pos.getCount()];
	for (int j=0; j < _pos.getCount(); j++) {
		[newpos addObject:[NSNumber numberWithFloat:_pos[j]]];
	}
	
	//new nor
	NSMutableArray * newnor = [NSMutableArray arrayWithCapacity:_nor.getCount()];
	for (int j=0; j < _nor.getCount(); j++) {
		[newnor addObject:[NSNumber numberWithFloat:_nor[j]]];
	}
	
	//new tex
	NSMutableArray * newtex = [NSMutableArray arrayWithCapacity:_pos.getCount()];
	for (int j=0; j < _pos.getCount(); j++) {
		[newtex addObject:[NSNumber numberWithFloat:-1.0]];
	}
	
	vector<domPolylist*> poly = db->typeLookup<domPolylist>();
	
	
	NSMutableArray * newind = [NSMutableArray arrayWithCapacity:1];
	
	//accorpate polylist
	for (size_t i=0; i < poly.size(); i++) {
		domP* p = (domP*)poly[i]->getChild("p");
		domListOfUInts  ind = p->getValue();
		
		
		for (int j=0; j < ind.getCount(); j++) {
			[newind addObject:[NSNumber numberWithInt:ind[j]]];
		}
	}
		
	//align pos-nor
	for (int j=0; j < [newind count]; j+=3) {
		NSNumber * j1 = (NSNumber *)[newind objectAtIndex:j];
		NSNumber * j2 = (NSNumber *)[newind objectAtIndex:j+1];
		
		if ([j1 unsignedIntValue] != [j2 unsignedIntValue]){
			[newind replaceObjectAtIndex:j+1 withObject:j1];
			[newnor replaceObjectAtIndex:[j1 unsignedIntValue]*3 withObject:[NSNumber numberWithFloat:_nor[[j2 unsignedIntValue]*3]]];
			[newnor replaceObjectAtIndex:[j1 unsignedIntValue]*3+1 withObject:[NSNumber numberWithFloat:_nor[[j2 unsignedIntValue]*3+1]]];
			[newnor replaceObjectAtIndex:[j1 unsignedIntValue]*3+2 withObject:[NSNumber numberWithFloat:_nor[[j2 unsignedIntValue]*3+2]]];
		}
	}
	
	
	//align pos-nor-tex
	NSMutableArray * duplicates_pos = [NSMutableArray arrayWithCapacity:0];
	NSMutableArray * duplicates_nor = [NSMutableArray arrayWithCapacity:0];
	NSMutableArray * duplicates_tex = [NSMutableArray arrayWithCapacity:0];
	
	for (int j=0; j < [newind count]; j+=3) {
		NSNumber * j1 = (NSNumber *)[newind objectAtIndex:j];
		NSNumber * j2 = (NSNumber *)[newind objectAtIndex:j+1];
		NSNumber * j3 = (NSNumber *)[newind objectAtIndex:j+2];
		
		NSNumber * posval_x = (NSNumber *)[newpos objectAtIndex:[j1 unsignedIntValue]*3];
		NSNumber * posval_y = (NSNumber *)[newpos objectAtIndex:[j1 unsignedIntValue]*3+1];
		NSNumber * posval_z = (NSNumber *)[newpos objectAtIndex:[j1 unsignedIntValue]*3+2];
		NSNumber * norval_x = (NSNumber *)[newnor objectAtIndex:[j2 unsignedIntValue]*3];
		NSNumber * norval_y = (NSNumber *)[newnor objectAtIndex:[j2 unsignedIntValue]*3+1];
		NSNumber * norval_z = (NSNumber *)[newnor objectAtIndex:[j2 unsignedIntValue]*3+2];
		float texval_s = _tex[[j3 unsignedIntValue]*2];
		float texval_t = _tex[[j3 unsignedIntValue]*2+1];
		NSNumber * newtexval_s = (NSNumber *)[newtex objectAtIndex:[j1 unsignedIntValue]*2];
		NSNumber * newtexval_t = (NSNumber *)[newtex objectAtIndex:[j1 unsignedIntValue]*2+1];
		
		if (f_equal(texval_s, [newtexval_s floatValue]) && f_equal(texval_t, [newtexval_t floatValue])){
			//caso 1 reuse tex
			[newind replaceObjectAtIndex:j+2 withObject:j1];
		} else {
			
			if (f_equal(-1.0, [newtexval_s floatValue]) && f_equal(-1.0, [newtexval_t floatValue])){
				//caso 2 add tex
				[newtex replaceObjectAtIndex:[j1 unsignedIntValue]*2 withObject:[NSNumber numberWithFloat:texval_s]];
				[newtex replaceObjectAtIndex:[j1 unsignedIntValue]*2+1 withObject:[NSNumber numberWithFloat:texval_t]];
				[newind replaceObjectAtIndex:j+2 withObject:j1];
				continue;
			}
			
			int found = 0;
			for (int k=0; k < [duplicates_pos count]/3; k++) {
				NSNumber * kx = (NSNumber *)[duplicates_pos objectAtIndex:k*3];
				NSNumber * ky = (NSNumber *)[duplicates_pos objectAtIndex:k*3+1];
				NSNumber * kz = (NSNumber *)[duplicates_pos objectAtIndex:k*3+2];
				NSNumber * ts = (NSNumber *)[duplicates_tex objectAtIndex:k*2];
				NSNumber * tt = (NSNumber *)[duplicates_tex objectAtIndex:k*2+1];
				
				if (f_equal([posval_x floatValue], [kx floatValue]) && f_equal([posval_y floatValue], [ky floatValue])
					&& f_equal([posval_z floatValue], [kz floatValue])
					&& f_equal(texval_s, [ts floatValue]) && f_equal(texval_t, [tt floatValue])){
					
					//caso 3 reuse duplicate
					
					found = 1;
					
					[newind replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:[newpos count]/3+k]];
					[newind replaceObjectAtIndex:j+1 withObject:[NSNumber numberWithInt:[newpos count]/3+k]];
					[newind replaceObjectAtIndex:j+2 withObject:[NSNumber numberWithInt:[newpos count]/3+k]];
					
					break;
				}
			}
			
			if (found == 0){
				//caso 4 add duplicate
				
				[duplicates_pos addObject:posval_x];
				[duplicates_pos addObject:posval_y];
				[duplicates_pos addObject:posval_z];
				[duplicates_nor addObject:norval_x];
				[duplicates_nor addObject:norval_y];
				[duplicates_nor addObject:norval_z];
				[duplicates_tex addObject:[NSNumber numberWithFloat:texval_s]];
				[duplicates_tex addObject:[NSNumber numberWithFloat:texval_t]];
				
				[newind replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:[newpos count]/3+[duplicates_pos count]/3-1]];
				[newind replaceObjectAtIndex:j+1 withObject:[NSNumber numberWithInt:[newpos count]/3+[duplicates_pos count]/3-1]];
				[newind replaceObjectAtIndex:j+2 withObject:[NSNumber numberWithInt:[newpos count]/3+[duplicates_pos count]/3-1]];
			}
		}

	}
	
	
	//unify
	for (int k=0; k < [duplicates_pos count]/3; k++) {
		[newpos addObject:[duplicates_pos objectAtIndex:k*3]];
		[newpos addObject:[duplicates_pos objectAtIndex:k*3+1]];
		[newpos addObject:[duplicates_pos objectAtIndex:k*3+2]];
		
		[newnor addObject:[duplicates_nor objectAtIndex:k*3]];
		[newnor addObject:[duplicates_nor objectAtIndex:k*3+1]];
		[newnor addObject:[duplicates_nor objectAtIndex:k*3+2]];
		
		[newtex addObject:[duplicates_tex objectAtIndex:k*2]];
		[newtex addObject:[duplicates_tex objectAtIndex:k*2+1]];
	}
	
	
	//verify
	//...
	
	
	
	NSMutableDictionary * propertyList = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  newpos, @"pos",
										  newnor, @"nor", 
										  newtex, @"tex",
										  [NSNumber numberWithInt:[newpos count]/3], @"num",
										  [NSNumber numberWithInt:poly.size()], @"polycount",
										   nil];
	
	//separate polylist
	int n = 0;
	for (size_t i=0; i < poly.size(); i++) {
		domP* p = (domP*)poly[i]->getChild("p");
		domListOfUInts  ind = p->getValue();
		
		NSMutableArray * _newind = [NSMutableArray arrayWithCapacity:0];
		
		for (int j=0; j < ind.getCount(); j++) {
			[_newind addObject:[newind objectAtIndex:n]];
			n++;
		}
		
		//indices
		NSString * ke = [NSString stringWithFormat:@"poly%d", i];
		[propertyList setObject:_newind forKey:ke];
		
		
		NSMutableDictionary * mat = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											   nil];
											  
		string at = poly[i]->getAttribute("material");
		at += "-effect";
		daeElement* elt = db->idLookup(at.c_str(), root->getDocument());
		domEffect * ef = (domEffect *)elt;
		get_material(ef, mat);
		
		//material
		NSString * ke1 = [NSString stringWithFormat:@"mat%d", i];
		[propertyList setObject:mat forKey:ke1];		
	}
	
	
	_write(propertyList, @"a.xml");
	

	[pool drain];
	
    return 0;
}
										  
										  
