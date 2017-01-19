(: xquery version "3.0"; :)

declare namespace ft="http://www.w3.org/2002/04/xquery-operators-text";
declare namespace CMDE="http://www.clarin.eu/cmd/1"; (: CMDI 1.2 Envelope, i.e. the general part of CMDI 1.2 instances:) 
declare namespace CMD="http://www.clarin.eu/cmd/"; (: This is the namespace used in CMDI 1.1 documents :)
declare namespace functx = "http://www.functx.com";
declare namespace marc = "http://www.loc.gov/MARC21/slim";

(: namespace CMDP for CMDI 1.2 Payload, i.e. the components, 
does not have to be declared for the purpose of this query, to keep it independent it will not be declared :)








declare function functx:is-node-in-sequence ($node as node()?, $seq as node()* )
as xs:boolean {
   some $nodeInSeq in $seq satisfies $nodeInSeq is $node
};

declare function functx:distinct-nodes ( $nodes as node()* )
as node()* {
    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(functx:is-node-in-sequence(
                                .,$nodes[position() < $seq]))]
};

declare variable $cmdCCSL external;
declare variable $cmdInstancepath external;


<marc:record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:marc="http://www.loc.gov/MARC21/slim"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
        type="Bibliographic">

  <marc:leader>00000pnm a22     n  4500</marc:leader>
{
(: This is the specification of the the mapping of facets to data categories :)
	let $dcConf := <datcatmap>
			<facet name="dc:title" tag="245" ind1="0" ind2="0" subfield_code="a">
			(: project name: A short name or abbreviation of the project that led to the creation of the resource or tool/service. :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2536_13fc5f10-c14a-1f64-a669-32736f6d3ef5</dcid>
			(: project title: The full title of the project that led to the creation of the resource or tool/service. :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2537_fa206273-223a-f4fa-dde3-ba59b965701f</dcid>		
			(: resource name: A short name to identify the language resource. :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2544_3626545e-a21d-058c-ebfd-241c0464e7e5</dcid>
			(: resource title: The title is the complete title of the resource without any abbreviations. :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2545_d873f2ab-2a2f-29d6-a9ab-260cde57f227</dcid>
			(: experiment name: Indication of a short name to identify an experimental study. :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3861_7e4f0289-04c6-fa24-25a2-1d8d248e6659</dcid>
			(: experiment title: Indication of the complete title of an experimental study. :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3862_6e6a3703-dd84-f12f-15e8-4327b0668145</dcid>
			(: book title: Indication of the title of a book :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4114_747bf046-1208-940d-36ba-297e4de49e0c</dcid>
			(: web service name: Name of a webservice  :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4160_192be757-0d8f-f4fe-b10b-d3d50de92482</dcid>
			(: original title: a descriptive or general heading as it appears in the resource :)
				<dcid>http://hdl.handle.net/11459/CCR_C-5127_f2721b23-921c-46ba-8d4d-88b46aef6976</dcid>
			(: title statement: groups information about the title of a work and those responsible for its content. :)
				<dcid>http://hdl.handle.net/11459/CCR_C-5428_65670fd6-3426-68ac-8f29-faef6ffd02ce</dcid>
			(: dc:title :)
				<dcid>http://purl.org/dc/terms/title</dcid>
				<dcid>http://purl.org/dc/elements/1.1/title</dcid>
			(: title work: contains a title for any kind of work :)
				<dcid>http://hdl.handle.net/11459/CCR_C-6119_ea4226b5-8d55-e71e-730f-2a02e3adbeb4</dcid>
			</facet>

			<facet name="dc:contributor" tag="720" ind1=" " ind2=" o" subfield_code="a">
				<dcid>http://hdl.handle.net/11459/CCR_C-3793_3bbfdf57-c9c8-c45b-f1c0-52773b1b9dbc</dcid> (: coop. partner :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4115_5da7f288-5384-5aaf-8d8e-fe4348165786</dcid> (: author :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4125_02e96f0d-768c-09cc-d3d6-bb553727a1fa</dcid> (: illustrator :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4128_9585c29d-5373-9efc-154c-41c101094047</dcid> (: corrector :)
                                <dcid>http://hdl.handle.net/11459/CCR_C-2512_e8061b33-c5f3-7f6c-184d-a4311549ba92</dcid> (: creator full name :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2513_f207a635-2563-5ded-907b-9dd4be99007c</dcid> (: creator role :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2542_d9c3586f-ca6c-2137-0b0e-8874b9a195be</dcid> (: metadata creator :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4118_0d368d47-dc1e-bdda-98e0-0cbb56040423</dcid> (: editor :)
			</facet>

                        <facet name="marc21:funder" tag="536" ind1=" " ind2=" " subfield_code="a">
				<dcid>http://hdl.handle.net/11459/CCR_C-2453_1f0c3ea5-7966-ae11-d3c6-448424d4e6e8</dcid> (: availability :)
			</facet>

                        (: should create appropriate information for tuebadz... :)
                        <facet name="marc21:funder" tag="536" ind1=" " ind2=" " subfield_code="a">
				<dcid>http://hdl.handle.net/11459/CCR_C-2522_3bdc6af1-bf1b-3f5d-2938-62d99a1980ab</dcid> (: funder :)
				<dcid>http://hdl.handle.net/11459/CCR_C-5414_55fd7a9e-edae-d8ad-a64f-c8e1058e7a6d</dcid> (: sponsor :)
			</facet>
			<facet name="dc:coverage" tag="513" ind1=" " ind2=" " subfield_code="b">
                                (: time coverage: The time period that the content of a resource is about.  :)
                                <dcid>http://hdl.handle.net/11459/CCR_C-2502_747eb0cd-03e9-cffb-34cc-d0c8c77e4c5a</dcid>
			</facet>

                        (: availability start date: http://hdl.handle.net/11459/CCR_C-6711_135e104e-9f0e-265a-0e6e-4e2325c8751e :)
                        (: availability end date:  http://hdl.handle.net/11459/CCR_C-6710_afb52a77-9f74-3123-2279-67ae4e256105:)

			<facet name="dc:date_derivation" tag="046" ind1=" " ind2=" " subfield_code="j">
				<dcid>http://hdl.handle.net/11459/CCR_C-2526_979ac535-eaa5-5e59-3cad-51c450234698</dcid> (: last update :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2515_82c31353-731f-c114-2f62-666bc48dbf8f</dcid> (: derivation date :) 
			</facet>

                        <facet name="dc:date_creation" tag="046" ind1=" " ind2=" " subfield_code="k">
				<dcid>http://hdl.handle.net/11459/CCR_C-2510_2402e609-046a-dfbf-c2d7-5a2f1ae6dc86</dcid> (: creation date :)
			</facet>

			<facet name="dc:date" tag="260" ind1=" " ind2=" " subfield_code="c">
				<dcid>http://hdl.handle.net/11459/CCR_C-2509_3b86afe2-ebde-ba09-8a1c-fe6bdc46a739</dcid> (: completion year :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2524_8ba4e008-208d-f6a9-8866-ac5c26126d69</dcid> (: harvesting date :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2538_8b697452-7ef3-9fce-ccf9-a7f344f11317</dcid> (: publication date :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2541_22927f62-5e6e-8b14-0393-3330ed5a7407</dcid> (: metadata creation date :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3694_bdf5e5c0-d4eb-8123-0a59-dfefd2d402ee</dcid> (: date, shoebox, last edited :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4117_a9394913-fb2e-7d45-332e-3785f5556d83</dcid> (: first publication :)
				<dcid>http://purl.org/dc/terms/created</dcid> (: date of creation :)
				<dcid>http://purl.org/dc/terms/date</dcid>   (: see also dateAccepted, dateCopyrighted, dateSubmitted :)
				<dcid>http://purl.org/dc/terms/issued</dcid> (: date of formal issuance :)
			</facet>
			<facet name="dc:description" tag="520" ind1=" " ind2=" " subfield_code="a">
				<dcid>http://hdl.handle.net/11459/CCR_C-2520_9eeedfb4-47d3-ddee-cfcb-99ac634bf1db</dcid>
				<dcid>http://hdl.handle.net/11459/CCR_C-6124_2e45fdf9-ced2-89c9-a09d-b4769e9fede6</dcid>
			</facet>
                        (: The file format, physical medium, or dimensions of the resource. :)
			<facet name="dc:format"  tag="856" ind1=" " ind2=" " subfield_code="q">
				<dcid>http://hdl.handle.net/11459/CCR_C-2465_4444eb51-7cf7-0ff7-7687-7f741f3a4f84</dcid> (: delivery format :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2562_872eb94a-47fb-b551-2f64-13ded063259e</dcid> (: annotation format :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2571_2be2e583-e5af-34c2-3673-93359ec1f7df</dcid> (: mime type :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2689_b7a745f7-1c1f-df1d-e50b-aa7a6435b39d</dcid> (: audio file format :)
                                <dcid>http://hdl.handle.net/11459/CCR_C-5191_edeaf1c0-dd17-1347-413d-966bf8525a13</dcid> (: videoTapeFormat :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4085_c4b5b45a-364e-1fc1-6321-5738ba4c2fa1</dcid> (: annotation scheme :)
			</facet>
                        (: if string contains with 'http://' then tag 856 40 $u, otherwise 024 8#$a :)
			<facet name="dc:identifier" tag="856" ind1=" " ind2=" " subfield_code="u">
				<dcid>http://hdl.handle.net/11459/CCR_C-3894_4d08cc31-25fe-af0c-add4-ca7bdc12f5f7</dcid> (: identifier :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4119_ad3a9349-db08-cefd-2c5e-0f311f3f0b54</dcid> (: isbn :)
				<dcid>http://hdl.handle.net/11459/CCR_C-4120_e2eef8bb-64aa-b046-d55f-31f48690ffc0</dcid> (: ismn :)
			</facet>
			<facet name="dc:language" tag="546" ind1=" " ind2=" " subfield_code="a">
				<dcid>http://hdl.handle.net/11459/CCR_C-2468_e4135e12-c272-171e-a8a2-48339228387b</dcid>
				<dcid>http://hdl.handle.net/11459/CCR_C-2482_08eded24-4086-7e3f-88e5-e0807fb01e17</dcid>
				<dcid>http://hdl.handle.net/11459/CCR_C-2483_96e89432-7591-d436-3921-5aa78e836924</dcid>
				<dcid>http://hdl.handle.net/11459/CCR_C-2484_669684e7-cb9e-ea96-59cb-a25fe89b9b9d</dcid>
				<dcid>http://hdl.handle.net/11459/CCR_C-2489_afd99796-8c92-7ae7-ef8c-a11b2560d8a0</dcid>
				<dcid>http://hdl.handle.net/11459/CCR_C-2543_800bf037-d733-846b-2d29-b86bccbd0841</dcid>
				<dcid>http://hdl.handle.net/11459/CCR_C-5358_3cd089fe-ad03-6181-b20c-635ea41ed818</dcid>
				<dcid>http://hdl.handle.net/11459/CCR_C-5361_ba085ec1-9746-52bf-8cc1-3c300ce16eb8</dcid>
			</facet>
                        (: 9 other entries in the ISOCat registry :)
			<facet name="dc:publisher" tag="260" ind1=" " ind2=" " subfield_code="b">
				<dcid>http://hdl.handle.net/11459/CCR_C-2459_fc4e74d6-84de-c8cd-1ae8-2c2be5ee90b1</dcid> (: organization:)
				<dcid>http://hdl.handle.net/11459/CCR_C-2979_8030473e-bbcb-6b87-3fd2-90554429ec50</dcid> (: Organisation :)
				<dcid>http://purl.org/dc/terms/publisher</dcid>
				<dcid>http://purl.org/dc/elements/1.1/publisher</dcid>
			</facet>
			<facet name="dc:relation">
			</facet>
			<facet name="dc:rights" tag="540" ind1=" " ind2=" " subfield_code="a">
				<dcid>http://hdl.handle.net/11459/CCR_C-2453_1f0c3ea5-7966-ae11-d3c6-448424d4e6e8</dcid> (: availability :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2456_8865d13f-d856-87fb-b559-965df28f7916</dcid> (: legal status of org :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3800_12a79edd-0ffe-8d82-9831-45d125c54aee</dcid> (: licence type :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2457_45bbaa1a-7002-2ecd-ab9d-57a189f694a6</dcid> (: license :)
			</facet>
			<facet name="dc:source" tag="786" ind1="0" ind2=" " subfield_code="n">
                                (: CZ Indicates the original resources that were at the base of the creation/derivation process. :)
                                <dcid>http://hdl.handle.net/11459/CCR_C-2534_04c8cf6a-4272-2213-4de7-52713b7c286f</dcid>
			</facet>
			
			<facet name="dc:type" tag="655" ind1=" " ind2="7" subfield_code="a"> (: the nature or genre of the discourse :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3786_21c37142-994f-63a8-5a5b-a9fce07681a7</dcid> (: appl. type :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3789_1572b49c-4e36-24db-4358-25324cd4b5cb</dcid> (: class. type :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3795_9ca13de7-965b-6a56-ebfb-9cfec61fac6e</dcid> (: distribution type :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2467_f4e7331f-b930-fc42-eeea-05e383cfaa78</dcid> (: domain :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3871_e49ed01e-3c9e-0c0e-0eaa-41833d2df899</dcid> (: experiment type :)
				<dcid>http://hdl.handle.net/11459/CCR_C-2487_472ad387-0b4e-3782-cb65-be9b20cb656d</dcid> (: lexicon type :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3804_6b1212ab-efcd-ec8c-4ff2-da70dd8f1be9</dcid> (: output type :)
				<dcid>http://hdl.handle.net/11459/CCR_C-3806_e55e9ed6-b099-c21d-a634-3c7f4d22a215</dcid> (: resource class :)
			</facet>
		</datcatmap>
		,
		$ccslinstance := $cmdCCSL,
		$cmdInstance := $cmdInstancepath
		
        (: in CMDI1.2 the CMD_Version attribute must be present :)
        return 
        if ($cmdInstance/*:CMD/@CMDVersion="1.2") 
        then
               for $facet in $dcConf//facet
	           return 
		          for $value in distinct-values(
			                     for $cmdDecl in $ccslinstance//Element,
				                        $dcid in $facet/dcid
			                     where contains($cmdDecl/@ConceptLink, $dcid/text())
			                     return
				                    for $cmd in $cmdInstance//CMDE:CMD/CMDE:Components//*
				                    where contains($cmd/name(), $cmdDecl/@name)
				                    return 
					                   for $txt in $cmd/text()
					                   return 
					                       if (normalize-space($txt) = '')
						                   then ()
						                  else $txt 
				                  )
        		return 
        		      <marc:datafield tag="{$facet/@tag}" ind1="{$facet/@ind1}" ind2="{$facet/@ind2}">
	                      <marc:subfield code="{$facet/@subfield_code}">
		      	      		{$value}
			             </marc:subfield>
		              </marc:datafield>       
        else		
	       for $facet in $dcConf//facet
	       return 
		      for $value in distinct-values(
			                 for $cmdDecl in $ccslinstance//CMD_Element,
				                $dcid in $facet/dcid
			                 where contains($cmdDecl/@ConceptLink, $dcid/text())
			                 return
				                for $cmd in $cmdInstance//CMD:CMD/CMD:Components//*
				                where contains($cmd/name(), $cmdDecl/@name)
				                return 
					               for $txt in $cmd/text()
					               return 
					                  if (normalize-space($txt) = '')
						              then ()
						              else $txt 
				              )

		      return
		          <marc:datafield tag="{$facet/@tag}" ind1="{$facet/@ind1}" ind2="{$facet/@ind2}">
	                      <marc:subfield code="{$facet/@subfield_code}">
			      		     {$value}
			             </marc:subfield>
		          </marc:datafield>
}
</marc:record>
