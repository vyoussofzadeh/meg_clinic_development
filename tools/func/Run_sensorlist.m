    Vertex = {'MEG0633','MEG0632','MEG0423','MEG0422','MEG0712', ...
        'MEG0713','MEG0433','MEG0432','MEG0742','MEG0743',...
        'MEG1822','MEG1823','MEG1043','MEG1042','MEG1112',...
        'MEG1113','MEG0722','MEG0723','MEG1142','MEG1143',...
        'MEG0732','MEG0733','MEG2212','MEG2213','MEG0631',...
        'MEG0421','MEG0711','MEG0431','MEG0741','MEG1821',...
        'MEG1041','MEG1111','MEG0721','MEG1141','MEG0731',...
        'MEG2211'};
    
    
    Left_temp = {'MEG0223','MEG0222','MEG0212','MEG0213','MEG0133', ...
        'MEG0132','MEG0112','MEG0113','MEG0233','MEG0232',...
        'MEG0243','MEG0242','MEG1512','MEG1513','MEG0143',...
        'MEG0142','MEG1623','MEG1622','MEG1613','MEG1612',...
        'MEG1523','MEG1522','MEG1543','MEG1542','MEG1533',...
        'MEG1532','MEG0221','MEG0211','MEG0131','MEG0111',...
        'MEG0231','MEG0241','MEG1511','MEG0141','MEG1621',...
        'MEG1611','MEG1521','MEG1541','MEG1531'};
    
    
    Right_temp = {'MEG1312','MEG1313','MEG1323','MEG1322','MEG1442', ...
        'MEG1443','MEG1423','MEG1422','MEG1342','MEG1343',...
        'MEG1333','MEG1332','MEG2612','MEG2613','MEG1433',...
        'MEG1432','MEG2413','MEG2412','MEG2422','MEG2423',...
        'MEG2642','MEG2643','MEG2623','MEG2622','MEG2633',...
        'MEG2632','MEG1311','MEG1321','MEG1441','MEG1421',...
        'MEG1341','MEG1331','MEG2611','MEG1431','MEG2411',...
        'MEG2421','MEG2641','MEG2621','MEG2631'};
    
    
    Left_pari = {'MEG0633','MEG0632','MEG0423','MEG0422','MEG0412',...
        'MEG0413','MEG0712','MEG0713','MEG0433','MEG0432',...
        'MEG0442','MEG0443','MEG0742','MEG0743','MEG1822',...
        'MEG1823','MEG1813','MEG1812','MEG1832','MEG1833',...
        'MEG1843','MEG1842','MEG1632','MEG1633','MEG2013',...
        'MEG2012','MEG0631','MEG0421','MEG0411','MEG0711',...
        'MEG0431','MEG0441','MEG0741','MEG1821','MEG1811',...
        'MEG1831','MEG1841','MEG1631','MEG2011'};
    
    
   Right_pari = {'MEG1043','MEG1042','MEG1112','MEG1113','MEG1123',...
        'MEG1122','MEG0722','MEG0723','MEG1142','MEG1143',...
        'MEG1133','MEG1132','MEG0732','MEG0733','MEG2212',...
        'MEG2213','MEG2223','MEG2222','MEG2242','MEG2243',...
        'MEG2232','MEG2233','MEG2442','MEG2443','MEG2023',...
        'MEG2022','MEG1041','MEG1111','MEG1121','MEG0721',...
        'MEG1141','MEG1131','MEG0731','MEG2211','MEG2221',...
        'MEG2241','MEG2231','MEG2441','MEG2021'};
    
    % left-occi
    left_occi = {'MEG2042','MEG2043','MEG1913','MEG1912','MEG2113',...
        'MEG2112','MEG1922','MEG1923','MEG1942','MEG1943',...
        'MEG1642','MEG1643','MEG1933','MEG1932','MEG1733',...
        'MEG1732','MEG1723','MEG1722','MEG2143','MEG2142',...
        'MEG1742','MEG1743','MEG1712','MEG1713','MEG2041',...
        'MEG1911','MEG2111','MEG1921','MEG1941','MEG1641',...
        'MEG1931','MEG1731','MEG1721','MEG2141','MEG1741',...
        'MEG1711'};
        
    % right-occi
    right_occi = {'MEG2032','MEG2033','MEG2313','MEG2312','MEG2342',...
        'MEG2343','MEG2322','MEG2323','MEG2433','MEG2432',...
        'MEG2122','MEG2123','MEG2333','MEG2332','MEG2513',...
        'MEG2512','MEG2523','MEG2522','MEG2133','MEG2132',...
        'MEG2542','MEG2543','MEG2532','MEG2533','MEG2031',...
        'MEG2311','MEG2341','MEG2321','MEG2431','MEG2121',...
        'MEG2331','MEG2511','MEG2521','MEG2131','MEG2541',...
        'MEG2531'};
        
    % left-front
    left_front = {'MEG0522','MEG0523','MEG0512','MEG0513','MEG0312',...
        'MEG0313','MEG0342','MEG0343','MEG0122','MEG0123',...
        'MEG0822','MEG0823','MEG0533','MEG0532','MEG0543',...
        'MEG0542','MEG0322','MEG0323','MEG0612','MEG0613',...
        'MEG0333','MEG0332','MEG0622','MEG0623','MEG0643',...
        'MEG0642','MEG0521','MEG0511','MEG0311','MEG0341',...
        'MEG0121','MEG0821','MEG0531','MEG0541','MEG0321',...
        'MEG0611','MEG0331','MEG0621','MEG0641'};
    
    
    % right-front
    right_front = {'MEG0813','MEG0812','MEG0912','MEG0913','MEG0922',...
        'MEG0923','MEG1212','MEG1213','MEG1223','MEG1222',...
        'MEG1412','MEG1413','MEG0943','MEG0942','MEG0933',...
        'MEG0932','MEG1232','MEG1233','MEG1012','MEG1013',...
        'MEG1022','MEG1023','MEG1243','MEG1242','MEG1033',...
        'MEG1032','MEG0811','MEG0911','MEG0921','MEG1211',...
        'MEG1221','MEG1411','MEG0941','MEG0931','MEG1231',...
        'MEG1011','MEG1021','MEG1241','MEG1031'};