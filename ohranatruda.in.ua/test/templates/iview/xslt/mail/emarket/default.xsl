<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE xsl:stylesheet SYSTEM "ulang://i18n/constants.dtd:file"[
    <!ENTITY nbsp  "&#xA0;">
    <!ENTITY copy  "&#169;">
    <!ENTITY mdash "&#8212;">
    
    <!ENTITY laquo  "&#171;">
    <!ENTITY raquo  "&#187;">
    
    <!ENTITY rarr  "&#8594;">
    <!ENTITY larr  "&#8592;">  
]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output encoding="utf-8" method="html" indent="yes" />

	<xsl:template match="status_notification">
		
		<xsl:variable name="order" select="document(concat('uobject://', order_id))" />
		<xsl:variable name="customer" select="document(concat('uobject://', $order//property[@name='customer_id']/value/item/@id))" />

		<xsl:choose>
			<xsl:when test="$order//property[@name='status_id']/value/item/@id = '18'">    <!-- 18 статус заказа: ожидает проверки -->
				<p>Здравствуйте, <strong><xsl:value-of select="$customer//property[@name='fio']//value" /></strong>!<br/>
				Вы оформили заказ <strong>#<xsl:value-of select="order_number" /></strong>, ниже приведены его детали.</p>
				<h4 style="background: #cdcdcd; padding-bottom: 0; margin-bottom: 0; font-size: 14px; width: 800px">Информация о заказе</h4>
				
				<table cellpadding="0" cellspacing="0" border="0" style="width:800px">
					<tr>
						<td width="50%; text-align: left"><xsl:text>Номер заказа:</xsl:text></td>
						<td width="50%"><xsl:value-of select="order_number" /></td>
					</tr>
					<tr>
						<td width="50%; text-align: left"><xsl:text>Дата заказа:</xsl:text></td>
						<td width="50%"><xsl:value-of select="document(concat('udata://system/convertDate/', $order//property[@name='order_date']/value/@unix-timestamp, '/Y-m-d%20H:i:s'))/udata" /></td>
					</tr>
					<tr>
						<td width="50%; text-align: left"><xsl:text>Статус заказа:</xsl:text></td>
						<td width="50%"><xsl:value-of select="$order//property[@name='status_id']/value/item/@name" /></td>
					</tr>
					<tr>
						<td width="50%; text-align: left"><xsl:text>Способ оплаты:</xsl:text></td>
						<td width="50%"><xsl:value-of select="$order//property[@name='payment_id']//value/item/@name" /></td>
					</tr>
					<tr>
						<td width="50%; text-align: left"><xsl:text>Способ доставки:</xsl:text></td>
						<td width="50%"><xsl:value-of select="$order//property[@name='delivery_id']//value/item/@name" /></td>
					</tr>					
				</table>
				
				<br/>
				
				<h4 style="background: #cdcdcd; padding-bottom: 0; margin-bottom: 0; font-size: 14px; width: 800px">Содержание заказа</h4>
				
				<table cellpadding="0" cellspacing="0" border="0" style="width:800px">
					<tr>
						<td style="text-align: left; font-weight: bold" width="15%">
							<xsl:text>Количество</xsl:text>
						</td>
						<td style="text-align: left; font-weight: bold" width="35%">
							<xsl:text>Название</xsl:text>
						</td>
						
						<td style="text-align: left; font-weight: bold" width="15%">
							<xsl:text>Цена</xsl:text>
						</td>
						<td style="text-align: left; font-weight: bold" width="20%">
							<xsl:text>Промежуточный итог</xsl:text>
						</td>
					</tr>
					
					<xsl:apply-templates select="$order//property[@name='order_items']/value/item" mode="order-item" />
					
					<tr><td colspan="5" style="height: 20px	">&#160;</td></tr>
					<tr>
						<td colspan="2">&#160;</td>
						<td style="text-align: left" colspan="3">Сумма заказа с учетом скидки:&#160;<xsl:value-of select="$order//property[@name='total_price']//value" />&#160;RUB<br/>Стоимость доставки и плата за отгрузку:&#160;<xsl:value-of select="$order//property[@name='delivery_price']//value" />&#160;RUB</td>
					</tr>
					
					<xsl:if test="$order//property[@name='order_discount_id']//item/@name!=''">
						<tr>
							<td colspan="2">&#160;</td>
							<td style="text-align: left" colspan="3">Скидка на заказ:&#160;
								<xsl:value-of select="$order//property[@name='order_discount_id']//item/@name" />
							</td>
						</tr>	
					</xsl:if>
									
				</table>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Ваш заказ #</xsl:text>
				<xsl:value-of select="order_number" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="status" />
			</xsl:otherwise>
		</xsl:choose>	
			
	</xsl:template>


	<xsl:template match="status_notification_receipt">
		
		<xsl:variable name="order" select="document(concat('uobject://', order_id))" />
		<xsl:variable name="customer" select="document(concat('uobject://', $order//property[@name='customer_id']/value/item/@id))" />
		
		<xsl:choose>
			<xsl:when test="$order//property[@name='status_id']/value/item/@id = '18'">
				<p>Здравствуйте, <strong><xsl:value-of select="concat($customer//property[@name='fname']//value,' ',$customer//property[@name='lname']//value)" /></strong>!<br/>
				Вы оформили заказ <strong>#<xsl:value-of select="order_number" /></strong>, ниже приведены его детали.</p>
				<h4 style="background: #cdcdcd; padding-bottom: 0; margin-bottom: 0; font-size: 14px; width: 800px">Информация о заказе</h4>
				
				<table cellpadding="0" cellspacing="0" border="0" style="width:800px">
					<tr>
						<td width="50%; text-align: left"><xsl:text>Номер заказа:</xsl:text></td>
						<td width="50%"><xsl:value-of select="order_number" /></td>
					</tr>
					<tr>
						<td width="50%; text-align: left"><xsl:text>Дата заказа:</xsl:text></td>
						<td width="50%"><xsl:value-of select="document(concat('udata://system/convertDate/', $order//property[@name='order_date']/value/@unix-timestamp, '/Y-m-d%20H:i:s'))/udata" /></td>
					</tr>
					<tr>
						<td width="50%; text-align: left"><xsl:text>Статус заказа:</xsl:text></td>
						<td width="50%"><xsl:value-of select="$order//property[@name='status_id']/value/item/@name" /></td>
					</tr>
					<tr>
						<td width="50%; text-align: left"><xsl:text>Способ оплаты:</xsl:text></td>
						<td width="50%"><xsl:value-of select="$order//property[@name='payment_id']//value/item/@name" /> (<a href="http://{domain}/emarket/receipt/{order_id}/{receipt_signature}/"><xsl:text>печать квитанции на оплату</xsl:text></a>)</td>
					</tr>
					<tr>
						<td width="50%; text-align: left"><xsl:text>Способ доставки:</xsl:text></td>
						<td width="50%"><xsl:value-of select="$order//property[@name='delivery_id']//value/item/@name" /></td>
					</tr>
					
				</table>
				
				<br/>
				
				<h4 style="background: #cdcdcd; padding-bottom: 0; margin-bottom: 0; font-size: 14px; width: 800px">Содержание заказа</h4>
				
				<table cellpadding="0" cellspacing="0" border="0" style="width:800px">
					<tr>
						<td style="text-align: left; font-weight: bold" width="15%">
							<xsl:text>Количество</xsl:text>
						</td>
						<td style="text-align: left; font-weight: bold" width="35%">
							<xsl:text>Название</xsl:text>
						</td>
						
						<td style="text-align: left; font-weight: bold" width="15%">
							<xsl:text>Цена</xsl:text>
						</td>
						<td style="text-align: left; font-weight: bold" width="20%">
							<xsl:text>Промежуточный итог</xsl:text>
						</td>
					</tr>
					
					<xsl:apply-templates select="$order//property[@name='order_items']/value/item" mode="order-item" />
					
					<tr><td colspan="5" style="height: 20px	">&#160;</td></tr>
					<tr>
						<td colspan="2">&#160;</td>
						
						<td style="text-align: left" colspan="3">
							<xsl:if test="$order//property[@name='order_discount_id']//item/@name!=''">
								<xsl:text>Скидка на заказ:&#160;</xsl:text>
								<xsl:value-of select="$order//property[@name='order_discount_id']//item/@name" />
								<xsl:text>&#160;RUB</xsl:text>
							</xsl:if>
							<xsl:text>Стоимость доставки и плата за отгрузку:&#160;</xsl:text>
							<xsl:value-of select="$order//property[@name='delivery_price']//value" />
							<xsl:text>&#160;RUB</xsl:text>
							<br/>
							<xsl:text>Итого к оплате:&#160;</xsl:text>
							<xsl:value-of select="$order//property[@name='total_price']//value" />
							<xsl:text>&#160;RUB</xsl:text>
						</td>
					</tr>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Ваш заказ #</xsl:text>
				<xsl:value-of select="order_number" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="status" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>


	<xsl:template match="neworder_notification">
		
		<xsl:variable name="order" select="document(concat('uobject://', order_id))" />
		<xsl:variable name="customer" select="document(concat('uobject://', $order//property[@name='customer_id']/value/item/@id))" />
		<xsl:variable name="address"  select="document(concat('uobject://', $order//property[@name='delivery_address']/value/item[1]/@id))/udata/object" />
		<xsl:variable name="address-string" select="concat($address//property[@name='index']/value,', ',$address//property[@name='region']/value,', ',$address//property[@name='city']/value,', ',$address//property[@name='street']/value,', д. ',$address//property[@name='house']/value,', кв.',$address//property[@name='flat']/value)" />
		
		<h4 style="background: #cdcdcd; padding-bottom: 0; margin-bottom: 0; font-size: 14px; width: 800px">Информация о заказе <xsl:text> (</xsl:text>
                    <a href="http://{domain}/admin/emarket/order_edit/{order_id}/">
                            <xsl:text>Просмотр</xsl:text>
                    </a>
                    <xsl:text>)</xsl:text></h4>
		
		<table cellpadding="0" cellspacing="0" border="0" style="width:800px">
			<tr>
				<td width="50%; text-align: left"><xsl:text>Номер заказа:</xsl:text></td>
				<td width="50%"><xsl:value-of select="order_number" /></td>
			</tr>
			<tr>
				<td width="50%; text-align: left"><xsl:text>Дата заказа:</xsl:text></td>
				<td width="50%"><xsl:value-of select="document(concat('udata://system/convertDate/', $order//property[@name='order_date']/value/@unix-timestamp, '/Y-m-d%20H:i:s'))/udata" /></td>
			</tr>
			<tr>
				<td width="50%; text-align: left"><xsl:text>Статус заказа:</xsl:text></td>
				<td width="50%"><xsl:value-of select="$order//property[@name='status_id']/value/item/@name" /></td>
			</tr>
			<tr>
				<td width="50%; text-align: left"><xsl:text>Способ оплаты:</xsl:text></td>
				<td width="50%"><xsl:value-of select="$order//property[@name='payment_id']//value/item/@name" /></td>
			</tr>
			<tr>
				<td width="50%; text-align: left"><xsl:text>Способ доставки:</xsl:text></td>
				<td width="50%"><xsl:value-of select="$order//property[@name='delivery_id']//value/item/@name" /></td>
			</tr>
			
		</table>
		
		<br/>
		
		<h4 style="background: #cdcdcd; padding-bottom: 0; margin-bottom: 0; font-size: 14px; width: 800px">Информация о клиенте</h4>
		
		<table cellpadding="0" cellspacing="0" border="0" style="width:800px">
			<tr>
				<td width="50%; text-align: left">
					<strong>Информация о клиенте</strong>					
					<table width="100%" cellpadding="0" cellspacing="0" style="width: 100%">
						<tr>
							<td width="50%; text-align: left">
								<xsl:text>E-mail:</xsl:text>
							</td>
							<td>
								<xsl:value-of select="$customer//property[@name='e-mail']//value" />
							</td>
						</tr>
					</table>
					
					<br/>
					
					<strong>Контактная информация плательщика</strong>
										
					<table width="100%" cellpadding="0" cellspacing="0" style="width: 100%">
						<tr>
							<td width="50%; text-align: left">
								<xsl:text>Имя:</xsl:text>
							</td>
							<td>
								<xsl:value-of select="$customer//property[@name='fname']//value" />
							</td>
						</tr>
						<tr>
							<td width="50%; text-align: left">
								<xsl:text>Отчество:</xsl:text>
							</td>
							<td>
								<xsl:value-of select="$customer//property[@name='father_name']//value" />
							</td>
						</tr>                                                
						<tr>
							<td width="50%; text-align: left">
								<xsl:text>Фамилия:</xsl:text>
							</td>
							<td>
								<xsl:value-of select="$customer//property[@name='lname']//value" />
							</td>
						</tr>
						<tr>
							<td width="50%; text-align: left">
								<xsl:text>Тип покупателя:</xsl:text>
							</td>
							<td>
								<xsl:value-of select="$customer//property[@name='groups']//value/item/@name" />
							</td>
						</tr>
						
					</table>
				</td>
				<td width="50%" valign="top">
					<strong>Адрес доставки</strong>
					
					<table width="100%" cellpadding="0" cellspacing="0" style="width: 100%">
					<tr>
						<td width="50%; text-align: left">
							<xsl:text>Адрес доставки:</xsl:text>
						</td>
						<td>
							<xsl:value-of select="$address-string" />
						</td>
					</tr>
					
					</table>
				</td>
			</tr>
		</table>
		
		<br/>
		
		<h4 style="background: #cdcdcd; padding-bottom: 0; margin-bottom: 0; font-size: 14px; width: 800px">Содержание заказа</h4>
		
		<table cellpadding="0" cellspacing="0" border="0" style="width:800px">
			<tr>
				<td style="text-align: left; font-weight: bold" width="15%">
					<xsl:text>Количество</xsl:text>
				</td>
				<td style="text-align: left; font-weight: bold" width="35%">
					<xsl:text>Название</xsl:text>
				</td>
				
				<td style="text-align: left; font-weight: bold" width="15%">
					<xsl:text>Цена</xsl:text>
				</td>
				<td style="text-align: left; font-weight: bold" width="20%">
					<xsl:text>Промежуточный итог</xsl:text>
				</td>
			</tr>
			
			<xsl:apply-templates select="$order//property[@name='order_items']/value/item" mode="order-item" />
			
			<tr>
				<td colspan="5" style="height: 20px	">&#160;</td>
			</tr>
			<tr>
				<td colspan="2">&#160;</td>						
				<td style="text-align: left" colspan="3">Сумма заказа с учетом скидки:&#160;<xsl:value-of select="$order//property[@name='total_price']//value" />&#160;RUB<br/>Стоимость доставки и плата за отгрузку:&#160;<xsl:value-of select="$order//property[@name='delivery_price']//value" />&#160;RUB</td>
			</tr>
					
			<xsl:if test="$order//property[@name='order_discount_id']//item/@name!=''">
				<tr>
					<td colspan="2">&#160;</td>
					<td style="text-align: left" colspan="3">Скидка на заказ:&#160;
						<xsl:value-of select="$order//property[@name='order_discount_id']//item/@name" />
					</td>
				</tr>	
			</xsl:if>
			
		</table>
		
	</xsl:template>
	
	
	<xsl:template match="item" mode="order-item">
		
		<xsl:variable name="item" select="document(concat('uobject://',@id))" />
		
		<tr>
			<td style="text-align: left">
				<xsl:value-of select="$item//property[@name='item_amount']//value" />
			</td>
			<td style="text-align: left">
				<xsl:value-of select="@name" />
			</td>
			
			<td style="text-align: left">
				
				<xsl:value-of select="$item//property[@name='item_price']//value" />&#160;RUB
			</td>
			<td style="text-align: left">
				<xsl:value-of select="$item//property[@name='item_total_price']//value" />&#160;RUB
			</td>
		</tr>
		
	</xsl:template>

</xsl:stylesheet>