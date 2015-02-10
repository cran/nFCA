#require 'SVuGy/SVuGy'
class MultistageFCA
  @@eNames = {}   #object hash
  @@aNames = {}   #attribute hash
  @@eMatrix ={}
  @@matrix = {}   #Hash table, key is object, value is array of corresponding attributes
  @@inverseMatrix = {} #Hash table, inverse, key is attribute, value is array of objects that have that attribute
  @@conceptCount = 0
  @@conceptTree = {}
  @@concepts = []
  @@children = []
  
  def initialize()
    
  end
  def matrix
    @@matrix
    
  end
  
  def concepts
    @@concepts
  end
  def aNames
    @@aNames
  end
  
  def ReadAncestry(filename, output)
    count = 0
    file = File.new(filename, "r")
    out = File.new(output,'w+')
    line = file.gets()
    data = line.strip().split(',')
    while !data.empty?
      print data[0..28].inspect + "\n"
      count +=1
      str = data[0].to_s + ":"
      
      for i in 3..28 do 
        if data[i]!="" or data[i].to_i >= 0
          str +=(i-2).to_s + ";"
        end
        
      end
      for i in 0..28 do
        data.delete_at(i)
      end
      str +="\n"
      out.puts(str)
    end
    file.close()
    out.close()
    print count
  end
  
  def ReadPedFile(filename, output)
    file = File.new(filename,"r")
    out = File.new(output,"w")
    count = 0
    
    file.each do |line|
      count +=1
      str = ""
      p_id,data = line.strip().split(',', 2)
      #print line.strip()
      #print p_id.to_s + "\n"
      #print data
      str = p_id.to_s+":"
      d = data.strip().split(',')
      
      for i in 2..d.length-1
        if d[i].to_i>=1
          str += (i-2).to_s + ";"
          
        end
      end
      str +="\n"
      out.puts(str)
    end
    print count
  end
  
  def ReadFile(filename)
    
    aInverse = {}
    eCount = aCount = 0
    aSeen = []
    file = File.new(filename, "r")
    
    #print file.readline
    file.each do |line|
      row = []
      e, aList = line.strip().split(':',2)
     if aList
      @@eNames[eCount] = e.strip()
      aList.split(';').each do |a|
        a=a.strip()
        if !aSeen.include?(a)
          aSeen += [a]
          @@aNames[aCount] = a
          aInverse[a]=aCount
          row << aCount
          if !@@inverseMatrix.include?(aCount)
            @@inverseMatrix[aCount]=[]
            
          end
          @@inverseMatrix[aInverse[a]] << eCount
          aCount +=1
        else
          row << aInverse[a]
          @@inverseMatrix[aInverse[a]] << eCount
        end
        row = row.sort()
        #print row.to_s + "\n"
        @@matrix[eCount]=row
      end
      
      eCount +=1
      end
    end
    
    file.close()
    
    
  end
  
  def AddConcept(tree, concept)
    if concept.empty?
      tree[-1] = @@conceptCount
      @@conceptCount +=1
      return tree[-1]
    else
      s = concept.length - 1
      tree[concept[0]]={}
      return self.AddConcept(tree[concept[0]], concept[1..s])
    end
  end
  #  class MultiStage(object):
  #        def AddConcept(self,tree,concept):
  #                if not concept:
  #                        tree[-1]=self.conceptCount
  #                        self.conceptCount+=1
  #                        return tree[-1]
  #                else:
  #                        tree[concept[0]]={}
  #                        return self.AddConcept(tree[concept[0]],concept[1:])
  #
  
  def CheckConcept(tree, concept)
    # checks for concept in tree, adds concept if it is not in tree
    if concept.empty? and tree.include?(-1)
      return tree[-1]
    elsif concept.empty? or !tree.include?(concept[0])
      return self.AddConcept(tree,concept)
    else
      s = concept.length() - 1
      return self.CheckConcept(tree[concept[0]], concept[1..s])
    end
  end
  #        def CheckConcept(self,tree,concept):
  #                """Checks for concept in tree,
  #                adds concept if it is not in tree
  #                returns True for new concept """
  #                if not concept and  -1 in tree:
  #                                return tree[-1]
  #                elif not concept or concept[0] not in tree:
  #                        return self.AddConcept(tree, concept)
  #                else:
  #                        return self.CheckConcept(tree[concept[0]], concept[1:])
  #

  def Intersection (a,b)
    ai = bi = 0
    result = []
    while ai<a.length and bi < b.length
      if a[ai] < b[bi]
        ai +=1
      elsif a[ai] > b[bi]
        bi+=1
      else
        result << a[ai]
        ai+=1
        bi+=1
      end
    end
    return result
  end
  #        def Intersection(self,a,b):
  #                """Get intersection of two sorted int lists"""
  #                ai=bi=0
  #                result=[]
  #                while ai<len(a) and bi<len(b):
  #                        if a[ai]<b[bi]:
  #                                ai+=1
  #                        elif a[ai]>b[bi]:
  #                                bi+=1
  #                        else:
  #                                result.append(a[ai])
  #                                ai+=1                   
  #                                bi+=1
  #                return result

  def IsSubset(a,b)
    if a.length > b.length
      return false
    end
    ai = bi = 0
    while ai<a.length and bi <b.length
      if a[ai] <b[bi]
        return false
      elsif a[ai]==b[bi]
        ai +=1
      end
      bi +=1
    end
    if ai<a.length
      return false
    else
      return true
    end
  end
  #        def IsSubset(self,a,b):
  #                """a is the smaller set"""
  #                if len(a)>len(b): return False
  #                ai=bi=0
  #                wh ile ai<len(a) and bi<len(b):
  #                        if a[ai]<b[bi]:
  #                                return False
  #                        elif a[ai]==b[bi]:
  #                                ai+=1
  #                        bi+=1
  #                if ai<len(a):
  #                        return False
  #                else:
  #                        return True

  def StartFCA(threshold1, threshold2)
    concepts = @@matrix.values
    i = 0
    while i <concepts.length
      if concepts[i+1..concepts.length-1].include?(concepts[i])
        concepts.delete_at(i)
      else
        i+=1
      end
    end
    
    if !concepts.include?(0..@@aNames.length-1)
      concepts << (0..@@aNames.length-1).to_a
    end
    
    @@conceptCount = 0
    concepts.each do |concept|
      self.CheckConcept(@@conceptTree, concept)
      
    end
    
    @@concepts = self.DoFCA(concepts,0, threshold1, threshold2)
  end
  #        def StartFCA(self):
  #                
  #                self.conceptTree={}
  #                concepts=self.matrix.values()
  #                i=0
  #                while i<len(concepts):
  #                        if concepts[i] in concepts[i+1:]:
  #                                del concepts[i]
  #                        else:
  #                                i+=1
  #                if range(len(self.aNames)) not in concepts:
  #                        concepts.append(range(len(self.aNames)))
  #                self.conceptCount=0
  #                for concept in concepts:
  #                        self.CheckConcept(self.conceptTree,concept)
  #                
  #                self.concepts=self.DoFCA(concepts,0)

  def DoFCA(concepts, start, threshold1, threshold2)
    newConcepts = []
    (start..concepts.length-1).each do |i|
      (i+1..concepts.length-1).each do |j|
        candidate = self.Intersection(concepts[i],concepts[j])
        if !candidate.empty?
          old = @@conceptCount
          id = self.CheckConcept(@@conceptTree, candidate)
          if old!=@@conceptCount
            if CountObj(candidate) >= threshold2 and candidate.length >= threshold1
              newConcepts << candidate
            end
          end
        end
      end
      
    end
    
    if !newConcepts.empty?
      oldLen = concepts.length
      newConcepts.each do |c|
        concepts << c
      end
      return self.DoFCA(concepts, oldLen,threshold1, threshold2)
    else
      return concepts
    end
  end
  #        def DoFCA(self,concepts,start):
  #                #print 'DoFCA',start
  #                newConcepts=[]
  #                for i in xrange(start,len(concepts)):
  #                        for j in xrange(i+1,len(concepts)):
  #                                candidate=self.Intersection(concepts[i],concepts[j])
  #                                if candidate:
  #                                        old=self.conceptCount
  #                                        id=self.CheckConcept(self.conceptTree,candidate)
  #                                        if old!=self.conceptCount:
  #                                                newConcepts.append(candidate)
  #                                                #self.PrintConcept(candidate)
  #                if newConcepts:
  #                        oldLen=len(concepts)
  #                        concepts.extend(newConcepts)
  #                        return self.DoFCA(concepts,oldLen)
  #                else:
  #                        return concepts
  #        def ReadFile(self, filename):
  #                """Read context from file (format: obj:att;att;att...)"""
  #                self.eNames={}
  #                self.aNames={}
  #                aInverse={}#temporary
  #                self.matrix={}
  #                self.inverseMatrix={}
  #                eCount=aCount=0
  #                aSeen=set()#temporary
  #                file=open(filename)
  #                for line in file:
  #                        row=[]
  #                        e, alist=line.strip().split(':',1)
  #                        self.eNames[eCount]=e.strip()
  #                        for a in alist.split(';'):
  #                                a=a.strip()
  #                                if a not in aSeen:
  #                                        aSeen.add(a)
  #                                        self.aNames[aCount]=a
  #                                        aInverse[a]=aCount
  #                                        row.append(aCount)
  #                                        if aCount not in self.inverseMatrix:
  #                                                self.inverseMatrix[aCount]=[]
  #                                        self.inverseMatrix[aCount].append(eCount)
  #                                        aCount+=1
  #                                else:
  #                                        row.append(aInverse[a])
  #                                        self.inverseMatrix[aInverse[a]].append(eCount)
  #                        row.sort()
  #                        self.matrix[eCount]=row
  #                        eCount+=1
  #             
  def PrintConcepts()
    @@concepts.sort {|x,y| x.length<=>y.length}.each do |concept|
      res = @@inverseMatrix[concept[0]]
        #res = Intersection(@@inverseMatrix[concept[0]], @@inverseMatrix[concept[1]])
        for j in 1..concept.length-1 do
          res = Intersection(res,@@inverseMatrix[concept[j]])
        end
      res.each do |e|
        print @@eNames[e]
      end
      print ':'
      for a in concept 
        print @@aNames[a]
      end
      print "\n"
    end
  end
  
  def PrintConcept(concept,index)
    str = '"'
    count = 0
    if !concept.empty?
      res = @@inverseMatrix[concept[0]]
        #res = Intersection(@@inverseMatrix[concept[0]], @@inverseMatrix[concept[1]])
        for j in 1..concept.length-1 do
          res = Intersection(res,@@inverseMatrix[concept[j]])
        end
      res.each do |e|
        count +=1
        str+=@@eNames[e].to_s+ ' '
      end
    else
      @@eNames.values.each do |name|
        count +=1
        str+=name.to_s+' '
      end
     
    end
    #file = File.open('outfiles2/file'+index.to_s,'w')
    #file.puts(str)
    #file.close
    
    #str='"file ' + index.to_s + ', ' + count.to_s + ':'
    #str += concept.length.to_s
	str += ':'
    concept.each do |a|
      str+=@@aNames[a].to_s+' '
    end
    str+='"'
    return str
  end
  #       def PrintConcept(self,concept,file):
  #                file.write( '"')
  #                if concept:
  #                        for e in reduce(self.Intersection,[self.inverseMatrix[row] for row in concept]):
  #                                file.write( self.eNames[e])
  #                else:
  #                        for name in self.eNames.itervalues():
  #                                file.write( name)
  #                file.write( ':')
  #                for a in concept:
  #                        file.write( self.aNames[a])
  #                file.write( '"')

  def PrintLattice(filename, cons=[])
    
    f=File.new(filename,'w')
    for i in (0..cons.length-1)
      @@children <<[]
      
    end
    #print @@children.inspect
    for i in (0..cons.length-1)
      #print "i: " + i.to_s 
      for j in (0..cons.length-1)
        #print "j: " + j.to_s
        if i!=j and self.IsSubset(cons[i],cons[j])
          @@children[j] << i
        end
      end
    end
    #print @@children.inspect
    f.puts("""graph lattice\n{\nranksep=2\n""")
    for i in (0..cons.length-1)
      str = ""
      if !@@children[i].empty?
        @@children[i].each do |c|
          @@children[i].each do |check|
            if @@children[check].include?(c)
              #print c.to_s + "\n"
              break
            end
            if check == @@children[i].last
              #print i.to_s + "\n"
              #print c.to_s + "\n"
              str = PrintConcept(cons[i],i)
              #str += " [URL=file:///file" + i.to_s + "]"
              str += " -- "
              str+= PrintConcept(cons[c],c)
              #str += " [URL=file:///file" + c.to_s + "]"
              f.puts(str)                           
            end
          end
        end
      else
        str = PrintConcept(cons[i],i)
        str +=" -- "
        str+=PrintConcept([],0)
        f.puts(str)
       
      end
    end
    f.puts("}")
    f.close()
  end
  #        def PrintLattice(self,filename=''):
  #                print self.concepts
  #                print self.children
  #                f=open(filename,'w+')
  #                self.children=[set() for i in xrange(len(self.concepts))]
  #                for i in xrange(len(self.concepts)):
  #                        for j in xrange(len(self.concepts)):
  #                                if i!=j and self.IsSubset(self.concepts[i],self.concepts[j]):
  #                                        self.children[j].add(i)
  #                f.write( """graph lattice\n{\nranksep=2\n""")
  #                for i in xrange(len(self.concepts)):
  #                #for i in xrange(len(self.concepts)-1,-1,-1):
  #                        if self.children[i]:
  #                                for c in self.children[i]:
  #                                        for check in self.children[i]:
  #                                                if c in self.children[check]:
  #                                                        break
  #                                        else:
  #                                                self.PrintConcept(self.concepts[i],f)
  #                                                f.write( " -- ")
  #                                                self.PrintConcept(self.concepts[c],f)
  #                                                f.write( '\n') 
  #                        else:
  #                                self.PrintConcept(self.concepts[i],f)
  #                                f.write(  " -- ")
  #                                self.PrintConcept([],f)
  #                                f.write( '\n') 
  #                f.write( '}\n') 
  #        
  #        if __name__ == '__main__':
  #            print 'Hello World'
  #       

  def CountObj(concept)
     res = @@inverseMatrix[concept[0]]
        #res = Intersection(@@inverseMatrix[concept[0]], @@inverseMatrix[concept[1]])
        for j in 1..concept.length-1 do
          res = Intersection(res,@@inverseMatrix[concept[j]])
      end
      return res.length
  end
  
  def PrintConceptNWB(concept,index)
    
  end
  def PrintNWB(filename,cons)
    
  
    file = File.open(filename, 'w+')
    file.puts("*Nodes " + cons.length().to_s)
    file.puts("id*int label*string")
    for i in 1..cons.length()
      file.puts(i.to_s+ " \"" + concepts[i-1].inspect + "\"")
    end
    file.puts("*UndirectedEdges")
    file.puts("source*int target*int")
    
    ###graph hereeeeee-----------
    for i in (0..cons.length-1)
      @@children <<[]
      
    end
    #print @@children.inspect
    for i in (0..cons.length-1)
      #print "i: " + i.to_s 
      for j in (0..cons.length-1)
        #print "j: " + j.to_s
        if i!=j and self.IsSubset(cons[i],cons[j])
          @@children[j] << i
        end
      end
    end
    for i in (0..cons.length-1)
      str = ""
      if !@@children[i].empty?
        @@children[i].each do |c|
          @@children[i].each do |check|
            if @@children[check].include?(c)
              #print c.to_s + "\n"
              break
            end
            if check == @@children[i].last
              #print i.to_s + "\n"
              #print c.to_s + "\n"
              str = (i+1).to_s
              #str += " [URL=file:///file" + i.to_s + "]"
              str += " "
              str+= (c+1).to_s
              #str += " [URL=file:///file" + c.to_s + "]"
              file.puts(str)                           
            end
          end
        end
      else
        str = (i+1).to_s
        str +=" "
        str+="1"
        file.puts(str)
       
      end
    end
    #-----------------there
    
    file.close()
  end
  
	m = MultistageFCA.new()
	m.ReadFile('example.oal')
	concepts = m.StartFCA(0,0)
	m.PrintLattice('example.dot', concepts)
  

end
